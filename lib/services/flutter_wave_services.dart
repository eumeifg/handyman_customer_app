import 'package:sun3ah_customer/main.dart';
import 'package:sun3ah_customer/model/booking_detail_model.dart';
import 'package:sun3ah_customer/network/rest_apis.dart';
import 'package:sun3ah_customer/services/razor_pay_services.dart';
import 'package:sun3ah_customer/utils/configs.dart';
import 'package:sun3ah_customer/utils/constant.dart';
import 'package:sun3ah_customer/utils/images.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:uuid/uuid.dart';

class FlutterWaveServices {
  final Customer customer = Customer(
    name: appStore.userName,
    phoneNumber: appStore.userContactNumber,
    email: appStore.userEmail,
  );

  void payWithFlutterWave({
    required BookingDetailResponse bookDetailData,
    required num totalAmount,
    required String flutterWavePublicKey,
    required String flutterWaveSecretKey,
    required bool isTestMode,
  }) async {
    String transactionId = Uuid().v1();

    Flutterwave flutterWave = Flutterwave(
      context: getContext,
      publicKey: flutterWavePublicKey,
      currency: appStore.currencyCode,
      redirectUrl: BASE_URL,
      txRef: transactionId,
      amount: totalAmount.validate().toStringAsFixed(0),
      customer: customer,
      paymentOptions: "card, payattitude, barter",
      customization: Customization(title: "Pay With Flutterwave", logo: appLogo),
      isTestMode: isTestMode,
    );

    await flutterWave.charge().then((value) {
      if (value.status == "successful") {
        appStore.setLoading(true);

        verifyPayment(transactionId: value.transactionId.validate(), flutterWaveSecretKey: flutterWaveSecretKey).then((v) {
          if (v.status == "success") {
            savePay(data: bookDetailData, paymentMethod: PAYMENT_METHOD_FLUTTER_WAVE, paymentStatus: SERVICE_PAYMENT_STATUS_PAID, txnId: value.transactionId.validate()).catchError(onError);
          } else {
            appStore.setLoading(false);
            toast(language.transactionFailed);
          }
        }).catchError((e) {
          appStore.setLoading(false);

          toast(e.toString());
        });
      } else {
        toast(language.lblTransactionCancelled);
        appStore.setLoading(false);
      }
    });
  }
}
