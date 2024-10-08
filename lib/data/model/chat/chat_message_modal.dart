class ChatMessageModal {
  int? id;
  int? senderId;
  int? receiverId;
  int? itemId;
  String? message;
  String? file;
  String? audio;
  String? createdAt;
  String? updatedAt;

  ChatMessageModal(
      {this.id,
      this.senderId,
      this.receiverId,
      this.itemId,
      this.message,
      this.file,
      this.audio,
      this.createdAt,
      this.updatedAt});

  ChatMessageModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    itemId = json['item_id'];
    message = json['message'];
    file = json['file'];
    audio = json['audio'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['item_id'] = itemId;
    data['message'] = message;
    data['file'] = file;
    data['audio'] = audio;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
