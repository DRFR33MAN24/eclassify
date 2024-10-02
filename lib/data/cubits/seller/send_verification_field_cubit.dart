

import 'package:eClassify/data/Repositories/seller/seller_verification_field_repository.dart';
import 'package:eClassify/exports/main_export.dart';



abstract class SendVerificationFieldState {}

class SendVerificationFieldInitial extends SendVerificationFieldState {}

class SendVerificationFieldInProgress extends SendVerificationFieldState {}

class SendVerificationFieldSuccess extends SendVerificationFieldState {
  
  final String message;

  SendVerificationFieldSuccess(this.message);
}

class SendVerificationFieldFail extends SendVerificationFieldState {
  final dynamic error;

  SendVerificationFieldFail(this.error);
}

class SendVerificationFieldCubit extends Cubit<SendVerificationFieldState> {
  SendVerificationFieldCubit() : super(SendVerificationFieldInitial());
  final SellerVerificationFieldRepository repository = SellerVerificationFieldRepository();




  void send({
    required Map<String, dynamic> data,
  }) async {
    try {
      emit(SendVerificationFieldInProgress());

      Map response = await repository.sendVerificationField(
          data: data);


      if (response['error'] == false) {
        emit(SendVerificationFieldSuccess(response['message']));
      } else {
        emit(SendVerificationFieldFail(response['message']));
      }
    } catch (e) {

      emit(SendVerificationFieldFail(e.toString()));
    }
  }
}
