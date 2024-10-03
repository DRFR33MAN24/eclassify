// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/data/Repositories/category_repository.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class FetchServiceSubCategoriesState {}

class FetchServiceSubCategoriesInitial extends FetchServiceSubCategoriesState {}

class FetchServiceSubCategoriesInProgress extends FetchServiceSubCategoriesState {}

class FetchServiceSubCategoriesSuccess extends FetchServiceSubCategoriesState {
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool hasError;
  final List<CategoryModel> categories;

  FetchServiceSubCategoriesSuccess({
    required this.total,
    required this.page,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchServiceSubCategoriesSuccess copyWith({
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? hasError,
    List<CategoryModel>? categories,
  }) {
    return FetchServiceSubCategoriesSuccess(
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

  factory FetchServiceSubCategoriesSuccess.fromMap(Map<String, dynamic> map) {
    return FetchServiceSubCategoriesSuccess(
      total: map['total'] as int,
      page: map[' page'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      categories: List<CategoryModel>.from(
        (map['categories']).map<CategoryModel>(
          (x) => CategoryModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchServiceSubCategoriesSuccess.fromJson(String source) =>
      FetchServiceSubCategoriesSuccess.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FetchServiceSubCategoriesSuccess(total: $total,  page: $page, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}

class FetchServiceSubCategoriesFailure extends FetchServiceSubCategoriesState {
  final String errorMessage;

  FetchServiceSubCategoriesFailure(this.errorMessage);
}

class FetchServiceSubCategoriesCubit extends Cubit<FetchServiceSubCategoriesState>
    with HydratedMixin {
  FetchServiceSubCategoriesCubit() : super(FetchServiceSubCategoriesInitial());

  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<void> fetchSubCategories(
      {bool? forceRefresh,
      bool? loadWithoutDelay,
      required int categoryId}) async {
    try {
      emit(FetchServiceSubCategoriesInProgress());

      DataOutput<CategoryModel> categories = await _categoryRepository
          .fetchServicesCategories(page: 1, categoryId: categoryId);

      emit(FetchServiceSubCategoriesSuccess(
          total: categories.total,
          categories: categories.modelList,
          page: 1,
          hasError: false,
          isLoadingMore: false));
    } catch (e) {
      emit(FetchServiceSubCategoriesFailure(e.toString()));
    }
  }

  List<CategoryModel> getSubCategories() {
    if (state is FetchServiceSubCategoriesSuccess) {
      return (state as FetchServiceSubCategoriesSuccess).categories;
    }

    return <CategoryModel>[];
  }

  Future<void> fetchSubCategoriesMore() async {
    try {
      if (state is FetchServiceSubCategoriesSuccess) {
        if ((state as FetchServiceSubCategoriesSuccess).isLoadingMore) {
          return;
        }
        emit(
            (state as FetchServiceSubCategoriesSuccess).copyWith(isLoadingMore: true));
        DataOutput<CategoryModel> result =
            await _categoryRepository.fetchServicesCategories(
          page: (state as FetchServiceSubCategoriesSuccess).page + 1,
        );

        FetchServiceSubCategoriesSuccess categoryState =
            (state as FetchServiceSubCategoriesSuccess);
        categoryState.categories.addAll(result.modelList);

        List<String> list = categoryState.categories.map((e) => e.url!).toList();
        await HelperUtils.precacheSVG(list);

        emit(FetchServiceSubCategoriesSuccess(
            isLoadingMore: false,
            hasError: false,
            categories: categoryState.categories,
            page: (state as FetchServiceSubCategoriesSuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchServiceSubCategoriesSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchServiceSubCategoriesSuccess) {
      return (state as FetchServiceSubCategoriesSuccess).categories.length <
          (state as FetchServiceSubCategoriesSuccess).total;
    }
    return false;
  }

  @override
  FetchServiceSubCategoriesState? fromJson(Map<String, dynamic> json) {
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchServiceSubCategoriesState state) {
    return null;
  }
}
