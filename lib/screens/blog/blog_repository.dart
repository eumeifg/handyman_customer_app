// region Blog API

import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/network/network_utils.dart';
import 'package:sun3ah_customer/screens/blog/model/blog_detail_response.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'model/blog_response_model.dart';

Future<List<BlogData>> getBlogListAPI({int? page, required List<BlogData> blogData, Function(bool)? lastPageCallback}) async {
  appStore.setLoading(true);

  BlogResponse res = BlogResponse.fromJson(await handleResponse(await buildHttpResponse('blog-list?status=1&per_page=$PER_PAGE_ITEM&page=$page', method: HttpMethod.GET)));

  if (page == 1) blogData.clear();

  blogData.addAll(res.data.validate());

  lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

  appStore.setLoading(false);

  return blogData;
}

//endregion

// region Get Blog Detail API
Future<BlogDetailResponse> getBlogDetailAPI(Map request) async {
  return BlogDetailResponse.fromJson(await handleResponse(await buildHttpResponse('blog-detail', request: request, method: HttpMethod.POST)));
}
//endregion
