import 'dart:convert';

import 'package:sun3ah_customer/component/back_widget.dart';
import 'package:sun3ah_customer/component/loader_widget.dart';
import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/network/network_utils.dart';
import 'package:sun3ah_customer/utils/common.dart';
import 'package:sun3ah_customer/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String? url;
  final String? accessToken;

  PaymentWebViewScreen({required this.url, this.accessToken});

  @override
  _PaymentWebViewScreenState createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  bool isInvoiceNumberFound = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    log('URL: $SADAD_API_URL/${widget.url}');
  }

  void getHtmlBody(String url) {
    get(Uri.parse(url)).then((value) {
      log(value.body);

      String txnId = parseHtmlString(value.body).removeAllWhiteSpace().splitBetween('TransactionNo:', 'InvoiceInformation').trim();

      if (txnId.isNotEmpty && txnId.startsWith('#SD')) {
        isInvoiceNumberFound = true;

        getSingleTrans(txnId.validate().replaceAll('#', ''));
      } else {
        toast(language.lblInvalidTransaction);
      }
    }).catchError(onError);
  }

  Future<void> getSingleTrans(String? txnId) async {
    var request = Request(
      'GET',
      Uri.parse('$SADAD_API_URL/api/transactions/getTransaction'),
    )..headers.addAll(buildHeaderTokens(sadadToken: widget.accessToken.validate(), isSadadPayment: true));
    var params = {
      "transactionno": txnId,
    };
    request.body = jsonEncode(params);

    log(request.url);
    log(request.body);

    appStore.setLoading(true);
    StreamedResponse response = await request.send();
    appStore.setLoading(false);

    print(response.statusCode);

    if (response.statusCode.isSuccessful()) {
      String body = await response.stream.bytesToString();
      Map res = jsonDecode(body);

      if (res['invoice']['invoicestatus']['name'] == 'Paid') {
        finish(context, txnId.validate());
      } else {
        finish(context, '');
      }
    } else {
      toast(errorSomethingWentWrong);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.payment, color: context.primaryColor, textColor: Colors.white, backWidget: BackWidget()),
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            WebView(
              initialUrl: '$SADAD_PAY_URL/${widget.url}',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                //
              },
              onPageStarted: (s) {
                log('Start: $s');
              },
              onPageFinished: (s) {
                log('End: $s');
                if (s.contains('https://sadadqa.com/invoicedetail')) getHtmlBody(s);
              },
              navigationDelegate: (NavigationRequest request) {
                log(request.url);
                return NavigationDecision.navigate;
              },
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
