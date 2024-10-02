// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../exports/main_export.dart';
import '../Repositories/item_buyer_repository.dart';
import '../model/data_output.dart';
import '../model/user_model.dart';

abstract class GetItemBuyerListState {}

class GetItemBuyerListInitial extends GetItemBuyerListState {}

class GetItemBuyerListInProgress extends GetItemBuyerListState {}

class GetItemBuyerListInternalProcess extends GetItemBuyerListState {}

class GetItemBuyerListSuccess extends GetItemBuyerListState {
  final int total;
  final bool hasError;
  final List<BuyerModel> itemBuyerList;

  GetItemBuyerListSuccess({
    required this.total,
    required this.hasError,
    required this.itemBuyerList,
  });

  GetItemBuyerListSuccess copyWith({
    int? total,
    bool? hasError,
    List<BuyerModel>? itemBuyerList,
  }) {
    return GetItemBuyerListSuccess(
      total: total ?? this.total,
      hasError: hasError ?? this.hasError,
      itemBuyerList: itemBuyerList ?? this.itemBuyerList,
    );
  }
}

class GetItemBuyerListFailed extends GetItemBuyerListState {
  final dynamic error;

  GetItemBuyerListFailed(this.error);
}

class GetItemBuyerListCubit extends Cubit<GetItemBuyerListState> {
  GetItemBuyerListCubit() : super(GetItemBuyerListInitial());
  final ItemBuyerRepository _itemBuyerRepository = ItemBuyerRepository();

  void fetchItemBuyer(int itemId) async {
    try {
      emit(GetItemBuyerListInProgress());

      DataOutput<BuyerModel> result =
          await _itemBuyerRepository.fetchItemBuyerList(itemId);

      emit(
        GetItemBuyerListSuccess(
          hasError: false,
          itemBuyerList: result.modelList,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(GetItemBuyerListFailed(e));
    }
  }

  void resetState() {
    emit(GetItemBuyerListInProgress());
  }

  List<BuyerModel> getItemBuyerList() {
    if (state is GetItemBuyerListSuccess) {
      return (state as GetItemBuyerListSuccess).itemBuyerList;
    } else {
      return [];
    }
  }
}
