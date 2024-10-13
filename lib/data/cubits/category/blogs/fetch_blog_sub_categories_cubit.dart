// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/data/Repositories/category_repository.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../Repositories/blog_category_repository.dart';
import '../../../model/blog_category_model.dart';

abstract class FetchBlogSubCategoriesState {}

class FetchBlogSubCategoriesInitial extends FetchBlogSubCategoriesState {}

class FetchBlogSubCategoriesInProgress extends FetchBlogSubCategoriesState {}

class FetchBlogSubCategoriesSuccess extends FetchBlogSubCategoriesState {
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool hasError;
  final List<BlogCategoryModel> categories;

  FetchBlogSubCategoriesSuccess({
    required this.total,
    required this.page,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchBlogSubCategoriesSuccess copyWith({
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? hasError,
    List<BlogCategoryModel>? categories,
  }) {
    return FetchBlogSubCategoriesSuccess(
      total: total ?? this.total,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      ' page': page,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'categories': categories.map((x) => x.toJson()).toList(),
    };
  }

  factory FetchBlogSubCategoriesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchBlogSubCategoriesSuccess(
      total: map['total'] as int,
      page: map[' page'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      categories: List<BlogCategoryModel>.from(
        (map['categories']).map<BlogCategoryModel>(
          (x) => BlogCategoryModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchBlogSubCategoriesSuccess.fromJson(String source) =>
      FetchBlogSubCategoriesSuccess.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FetchBlogSubCategoriesSuccess(total: $total,  page: $page, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}

class FetchBlogSubCategoriesFailure extends FetchBlogSubCategoriesState {
  final String errorMessage;

  FetchBlogSubCategoriesFailure(this.errorMessage);
}

class FetchBlogSubCategoriesCubit extends Cubit<FetchBlogSubCategoriesState>
    with HydratedMixin {
  FetchBlogSubCategoriesCubit() : super(FetchBlogSubCategoriesInitial());

  final BlogCategoryRepository _categoryRepository = BlogCategoryRepository();

  Future<void> fetchSubCategories(
      {bool? forceRefresh,
      bool? loadWithoutDelay,
      required int categoryId}) async {
    try {
      emit(FetchBlogSubCategoriesInProgress());

      DataOutput<BlogCategoryModel> categories = await _categoryRepository
          .fetchCategories(page: 1, categoryId: categoryId);

      emit(FetchBlogSubCategoriesSuccess(
          total: categories.total,
          categories: categories.modelList,
          page: 1,
          hasError: false,
          isLoadingMore: false));
    } catch (e) {
      emit(FetchBlogSubCategoriesFailure(e.toString()));
    }
  }

  List<BlogCategoryModel> getSubCategories() {
    if (state is FetchBlogSubCategoriesSuccess) {
      return (state as FetchBlogSubCategoriesSuccess).categories;
    }

    return <BlogCategoryModel>[];
  }

  Future<void> fetchSubCategoriesMore() async {
    try {
      if (state is FetchBlogSubCategoriesSuccess) {
        if ((state as FetchBlogSubCategoriesSuccess).isLoadingMore) {
          return;
        }
        emit(
            (state as FetchBlogSubCategoriesSuccess).copyWith(isLoadingMore: true));
        DataOutput<BlogCategoryModel> result =
            await _categoryRepository.fetchCategories(
          page: (state as FetchBlogSubCategoriesSuccess).page + 1,
        );

        FetchBlogSubCategoriesSuccess categoryState =
            (state as FetchBlogSubCategoriesSuccess);
        categoryState.categories.addAll(result.modelList);

        List<String> list = categoryState.categories.map((e) => e.url!).toList();
        await HelperUtils.precacheSVG(list);

        emit(FetchBlogSubCategoriesSuccess(
            isLoadingMore: false,
            hasError: false,
            categories: categoryState.categories,
            page: (state as FetchBlogSubCategoriesSuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchBlogSubCategoriesSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchBlogSubCategoriesSuccess) {
      return (state as FetchBlogSubCategoriesSuccess).categories.length <
          (state as FetchBlogSubCategoriesSuccess).total;
    }
    return false;
  }

  @override
  FetchBlogSubCategoriesState? fromJson(Map<String, dynamic> json) {
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchBlogSubCategoriesState state) {
    return null;
  }
}
