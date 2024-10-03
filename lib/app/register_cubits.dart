import 'package:eClassify/data/Repositories/favourites_repository.dart';
import 'package:eClassify/data/add_item_review_cubit.dart';

import 'package:eClassify/data/cubits/Location/fetch_cities_cubit.dart';
import 'package:eClassify/data/cubits/Location/fetch_countries_cubit.dart';
import 'package:eClassify/data/cubits/Location/fetch_states_cubit.dart';
import 'package:eClassify/data/cubits/auth/delete_user_cubit.dart';
import 'package:eClassify/data/cubits/category/items/fetch_sub_categories_cubit.dart';
import 'package:eClassify/data/cubits/chatCubits/block_user_cubit.dart';
import 'package:eClassify/data/cubits/chatCubits/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/chatCubits/unblock_user_cubit.dart';

import 'package:eClassify/data/cubits/fetch_faqs_cubit.dart';

import 'package:eClassify/data/cubits/item/search_item_cubit.dart';
import 'package:eClassify/data/cubits/safety_tips_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_item_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/cubits/seller/send_verification_field_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_featured_subscription_packages_cubit.dart';
import 'package:nested/nested.dart';
import '../data/cubits/CustomField/fetch_custom_fields_cubit.dart';


import '../data/cubits/Location/fetch_areas_cubit.dart';
import '../data/cubits/Report/item_report_cubit.dart';
import '../data/cubits/Report/update_report_items_list_cubit.dart';
import '../data/cubits/auth/authentication_cubit.dart';
import '../data/cubits/chatCubits/delete_message_cubit.dart';
import '../data/cubits/chatCubits/get_buyer_chat_users_cubit.dart';
import '../data/cubits/chatCubits/get_seller_chat_users_cubit.dart';
import '../data/cubits/chatCubits/load_chat_messages.dart';
import '../data/cubits/chatCubits/make_an_offer_item_cubit.dart';
import '../data/cubits/chatCubits/send_message.dart';
import '../data/cubits/fetch_item_buyer_cubit.dart';
import '../data/cubits/item/change_my_items_status_cubit.dart';
import '../data/cubits/item/create_featured_ad_cubit.dart';
import '../data/cubits/item/delete_item_cubit.dart';
import '../data/cubits/item/fetch_my_item_cubit.dart';
import '../data/cubits/item/item_total_click_cubit.dart';
import '../data/cubits/item/related_item_cubit.dart';
import '../data/cubits/seller/fetch_seller_verification_field.dart';
import '../data/cubits/seller/fetch_verification_request_cubit.dart';
import '../data/cubits/subscription/In_app_purchase_cubit.dart';
import '../data/cubits/subscription/assign_free_package_cubit.dart';
import '../data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import '../data/cubits/subscription/get_payment_intent_cubit.dart';

import '../data/cubits/ServiceFavorite/favoriteCubit.dart' as Service;
import '../data/cubits/ServiceFavorite/manageFavCubit.dart' as Service;


import '../data/cubits/Home/fetch_home_all_items_cubit.dart' as Item;
import '../data/cubits/Home/fetch_home_screen_cubit.dart' as Item;
import '../data/cubits/ServiceHome/fetch_home_all_items_cubit.dart' as Service;
import '../data/cubits/ServiceHome/fetch_home_screen_cubit.dart' as Service;
import 'package:eClassify/data/cubits/favorite/favoriteCubit.dart' as Item;
import 'package:eClassify/data/cubits/favorite/manageFavCubit.dart' as Item;
import 'package:eClassify/data/cubits/item/fetch_my_promoted_items_cubit.dart' as Item;
  import 'package:eClassify/data/cubits/service/fetch_my_promoted_items_cubit.dart' as Service;
import 'package:eClassify/data/cubits/item/fetch_popular_items_cubit.dart' as Item;
import 'package:eClassify/data/cubits/service/fetch_popular_items_cubit.dart' as Service;

import 'package:eClassify/data/cubits/item/search_item_cubit.dart' as Item;
import 'package:eClassify/data/cubits/service/search_item_cubit.dart' as Service;
import 'package:eClassify/data/cubits/Home/fetch_section_items_cubit.dart' as Item;
import 'package:eClassify/data/cubits/ServiceHome/fetch_section_items_cubit.dart' as Service;
import 'package:eClassify/data/cubits/service/fetch_item_from_category_cubit.dart' as Service;


import '../exports/main_export.dart';

class RegisterCubits {
  List<SingleChildWidget> providers = [
       BlocProvider(create: (context) => Item.FavoriteCubit(FavoriteRepository())),
    BlocProvider(create: (context) => Service.FavoriteCubit(FavoriteRepository())),
    BlocProvider(
        create: (context) => Item.UpdateFavoriteCubit(FavoriteRepository())),
    BlocProvider(create: (context) => Service.UpdateFavoriteCubit(FavoriteRepository())),
    BlocProvider(create: (context) => AuthCubit()),
    BlocProvider(create: (context) => LoginCubit()),
    BlocProvider(create: (context) => SliderCubit()),
    BlocProvider(create: (context) => CompanyCubit()),
    BlocProvider(create: (context) => FetchCategoryCubit()),
    BlocProvider(create: (context) => ProfileSettingCubit()),
    BlocProvider(create: (context) => NotificationCubit()),
    BlocProvider(create: (context) => AppThemeCubit()),
    BlocProvider(create: (context) => FetchItemFromCategoryCubit()),
        BlocProvider(create: (context) => Service.FetchItemFromCategoryCubit()),
    BlocProvider(create: (context) => FetchNotificationsCubit()),
    BlocProvider(create: (context) => LanguageCubit()),
    BlocProvider(create: (context) => FetchBlogsCubit()),
    BlocProvider(create: (context) => FetchSystemSettingsCubit()),
    BlocProvider(create: (context) => UserDetailsCubit()),
    BlocProvider(create: (context) => FetchLanguageCubit()),
        BlocProvider(create: (context) => Item.FetchMyPromotedItemsCubit()),
    BlocProvider(create: (context) => Service.FetchMyPromotedItemsCubit()),
    BlocProvider(
        create: (context) => FetchAdsListingSubscriptionPackagesCubit()),
    BlocProvider(create: (context) => FetchFeaturedSubscriptionPackagesCubit()),
    BlocProvider(create: (context) => GetApiKeysCubit()),
    BlocProvider(create: (context) => GetBuyerChatListCubit()),
    BlocProvider(create: (context) => GetSellerChatListCubit()),
    BlocProvider(create: (context) => FetchItemReportReasonsListCubit()),
    BlocProvider(create: (context) => ItemEditCubit()),
    BlocProvider(create: (context) => Item.FetchHomeScreenCubit()),
    BlocProvider(create: (context) => Service.FetchHomeScreenCubit()),
    BlocProvider(create: (context) => AuthenticationCubit()),
    BlocProvider(create: (context) => Item.FetchHomeScreenCubit()),
    BlocProvider(create: (context) => Service.FetchHomeScreenCubit()),
    BlocProvider(create: (context) => Item.FetchHomeAllItemsCubit()),
    BlocProvider(create: (context) => Service.FetchHomeAllItemsCubit()),
    BlocProvider(create: (context) => DeleteItemCubit()),
    BlocProvider(create: (context) => ItemTotalClickCubit()),
    BlocProvider(create: (context) => Item.FetchSectionItemsCubit()),
    BlocProvider(create: (context) => Service.FetchSectionItemsCubit()),
    BlocProvider(create: (context) => ItemReportCubit()),
    BlocProvider(create: (context) => FetchRelatedItemsCubit()),
    BlocProvider(create: (context) => Item.FetchPopularItemsCubit()),
    BlocProvider(create: (context) => Service.FetchPopularItemsCubit()),
    BlocProvider(create: (context) => Item.SearchItemCubit()),
    BlocProvider(create: (context) => Service.SearchItemCubit()),
    BlocProvider(create: (context) => SearchItemCubit()),
    BlocProvider(create: (context) => FetchSubCategoriesCubit()),
    BlocProvider(create: (context) => ChangeMyItemStatusCubit()),
    BlocProvider(create: (context) => CreateFeaturedAdCubit()),
    BlocProvider(create: (context) => AssignFreePackageCubit()),
    BlocProvider(create: (context) => FetchUserPackageLimitCubit()),
    BlocProvider(create: (context) => GetPaymentIntentCubit()),
    BlocProvider(create: (context) => DeleteUserCubit()),
    BlocProvider(create: (context) => MakeAnOfferItemCubit()),
    BlocProvider(create: (context) => InAppPurchaseCubit()),
    BlocProvider(create: (context) => SendMessageCubit()),
    BlocProvider(create: (context) => DeleteMessageCubit()),
    BlocProvider(create: (context) => LoadChatMessagesCubit()),
    BlocProvider(create: (context) => FetchMyItemsCubit()),
    BlocProvider(create: (context) => UpdatedReportItemCubit()),
    BlocProvider(create: (context) => BlockedUsersListCubit()),
    BlocProvider(create: (context) => BlockUserCubit()),
    BlocProvider(create: (context) => UnblockUserCubit()),
    BlocProvider(create: (context) => FetchSafetyTipsListCubit()),
    BlocProvider(create: (context) => FetchCustomFieldsCubit()),
    BlocProvider(create: (context) => FetchCountriesCubit()),
    BlocProvider(create: (context) => FetchStatesCubit()),
    BlocProvider(create: (context) => FetchCitiesCubit()),
    BlocProvider(create: (context) => FetchAreasCubit()),
    BlocProvider(create: (context) => FetchFaqsCubit()),
    BlocProvider(create: (context) => GetItemBuyerListCubit()),
    BlocProvider(create: (context) => FetchSellerItemsCubit()),
    BlocProvider(create: (context) => AddItemReviewCubit()),
    BlocProvider(create: (context) => FetchSellerRatingsCubit()),
    BlocProvider(create: (context) => FetchSellerVerificationFieldsCubit()),
    BlocProvider(create: (context) => SendVerificationFieldCubit()),
    BlocProvider(create: (context) => FetchVerificationRequestsCubit()),
  ];
}
