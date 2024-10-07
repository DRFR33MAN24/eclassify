// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:eClassify/data/Repositories/blog_category_repository.dart';
import 'package:eClassify/data/model/blog_category_model.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/data/Repositories/category_repository.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class FetchBlogCategoryState {}

class FetchBlogCategoryInitial extends FetchBlogCategoryState {}

class FetchBlogCategoryInProgress extends FetchBlogCategoryState {}

class FetchBlogCategorySuccess extends FetchBlogCategoryState {
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool hasError;
  final List<BlogCategoryModel> categories;

  FetchBlogCategorySuccess({
    required this.total,
    required this.page,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchBlogCategorySuccess copyWith({
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? hasError,
    List<BlogCategoryModel>? categories,
  }) {
    return FetchBlogCategorySuccess(
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

  factory FetchBlogCategorySuccess.fromMap(Map<String, dynamic> map) {
    return FetchBlogCategorySuccess(
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

  factory FetchBlogCategorySuccess.fromJson(String source) =>
      FetchBlogCategorySuccess.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FetchBlogCategorySuccess(total: $total,  page: $page, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}

class FetchBlogCategoryFailure extends FetchBlogCategoryState {
  final String errorMessage;

  FetchBlogCategoryFailure(this.errorMessage);
}

class FetchBlogCategoryCubit extends Cubit<FetchBlogCategoryState> with HydratedMixin {
  FetchBlogCategoryCubit() : super(FetchBlogCategoryInitial());

  final BlogCategoryRepository _categoryRepository = BlogCategoryRepository();

  Future<void> fetchCategories(
      {bool? forceRefresh, bool? loadWithoutDelay}) async {
    try {
      emit(FetchBlogCategoryInProgress());

      DataOutput<BlogCategoryModel> categories =
          await _categoryRepository.fetchCategories(page: 1);


      emit(FetchBlogCategorySuccess(
          total: categories.total,
          categories: categories.modelList,
          page: 1,
          hasError: false,
          isLoadingMore: false));
    } catch (e) {
      emit(FetchBlogCategoryFailure(e.toString()));
    }
  }

  List<BlogCategoryModel> getCategories() {
    if (state is FetchBlogCategorySuccess) {
      return (state as FetchBlogCategorySuccess).categories;
    }

    return <BlogCategoryModel>[];
  }

  Future<void> fetchCategoriesMore() async {
    try {
      if (state is FetchBlogCategorySuccess) {
        if ((state as FetchBlogCategorySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchBlogCategorySuccess).copyWith(isLoadingMore: true));
        DataOutput<BlogCategoryModel> result =
            await _categoryRepository.fetchCategories(
          page: (state as FetchBlogCategorySuccess).page + 1,
        );

        FetchBlogCategorySuccess categoryState = (state as FetchBlogCategorySuccess);
        categoryState.categories.addAll(result.modelList);

        List<String> list =
            categoryState.categories.map((e) => e.url!).toList();
        await HelperUtils.precacheSVG(list);

        emit(FetchBlogCategorySuccess(
            isLoadingMore: false,
            hasError: false,
            categories: categoryState.categories,
            page: (state as FetchBlogCategorySuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchBlogCategorySuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchBlogCategorySuccess) {
      return (state as FetchBlogCategorySuccess).categories.length <
          (state as FetchBlogCategorySuccess).total;
    }
    return false;
  }

  @override
  FetchBlogCategoryState? fromJson(Map<String, dynamic> json) {
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchBlogCategoryState state) {
    return null;
  }
}
