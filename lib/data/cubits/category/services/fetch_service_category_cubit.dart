// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/data/Repositories/category_repository.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class FetchServiceCategoryState {}

class FetchServiceCategoryInitial extends FetchServiceCategoryState {}

class FetchServiceCategoryInProgress extends FetchServiceCategoryState {}

class FetchServiceCategorySuccess extends FetchServiceCategoryState {
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool hasError;
  final List<CategoryModel> categories;

  FetchServiceCategorySuccess({
    required this.total,
    required this.page,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchServiceCategorySuccess copyWith({
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? hasError,
    List<CategoryModel>? categories,
  }) {
    return FetchServiceCategorySuccess(
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

  factory FetchServiceCategorySuccess.fromMap(Map<String, dynamic> map) {
    return FetchServiceCategorySuccess(
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

  factory FetchServiceCategorySuccess.fromJson(String source) =>
      FetchServiceCategorySuccess.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FetchServiceCategorySuccess(total: $total,  page: $page, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}

class FetchServiceCategoryFailure extends FetchServiceCategoryState {
  final String errorMessage;

  FetchServiceCategoryFailure(this.errorMessage);
}

class FetchServiceCategoryCubit extends Cubit<FetchServiceCategoryState> with HydratedMixin {
  FetchServiceCategoryCubit() : super(FetchServiceCategoryInitial());

  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<void> fetchCategories(
      {bool? forceRefresh, bool? loadWithoutDelay}) async {
    try {
      emit(FetchServiceCategoryInProgress());

      DataOutput<CategoryModel> categories =
          await _categoryRepository.fetchServicesCategories(page: 1);


      emit(FetchServiceCategorySuccess(
          total: categories.total,
          categories: categories.modelList,
          page: 1,
          hasError: false,
          isLoadingMore: false));
    } catch (e) {
      emit(FetchServiceCategoryFailure(e.toString()));
    }
  }

  List<CategoryModel> getCategories() {
    if (state is FetchServiceCategorySuccess) {
      return (state as FetchServiceCategorySuccess).categories;
    }

    return <CategoryModel>[];
  }

  Future<void> fetchCategoriesMore() async {
    try {
      if (state is FetchServiceCategorySuccess) {
        if ((state as FetchServiceCategorySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchServiceCategorySuccess).copyWith(isLoadingMore: true));
        DataOutput<CategoryModel> result =
            await _categoryRepository.fetchServicesCategories(
          page: (state as FetchServiceCategorySuccess).page + 1,
        );

        FetchServiceCategorySuccess categoryState = (state as FetchServiceCategorySuccess);
        categoryState.categories.addAll(result.modelList);

        List<String> list =
            categoryState.categories.map((e) => e.url!).toList();
        await HelperUtils.precacheSVG(list);

        emit(FetchServiceCategorySuccess(
            isLoadingMore: false,
            hasError: false,
            categories: categoryState.categories,
            page: (state as FetchServiceCategorySuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchServiceCategorySuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchServiceCategorySuccess) {
      return (state as FetchServiceCategorySuccess).categories.length <
          (state as FetchServiceCategorySuccess).total;
    }
    return false;
  }

  @override
  FetchServiceCategoryState? fromJson(Map<String, dynamic> json) {
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchServiceCategoryState state) {
    return null;
  }
}
