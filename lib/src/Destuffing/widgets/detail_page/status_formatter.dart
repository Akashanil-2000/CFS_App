String formatStatus(String? custom, String? payment) {
  final c = (custom ?? "").toLowerCase();
  final p = (payment ?? "").toLowerCase();

  String cText = c == "cleared" ? "Customs Cleared" : "Customs $custom";
  String pText = p == "completed" ? "Payment Completed" : "Payment $payment";

  return "$cText • $pText";
}

String formatCustomStatus(String? s) {
  if ((s ?? "").toLowerCase() == "cleared") return "Customs Cleared";
  return "Customs ${s ?? "-"}";
}

String formatPaymentStatus(String? s) {
  if ((s ?? "").toLowerCase() == "completed") return "Payment Completed";
  return "Payment ${s ?? "-"}";
}
