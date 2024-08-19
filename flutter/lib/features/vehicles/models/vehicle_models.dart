

import 'package:riverpod/riverpod.dart';

class SelectedCustomerModels {
  List customer = [];
  SelectedCustomerModels({List? customer});
  
  void addSelectedCustomer(Map selectedCustomer) {
    customer.add(selectedCustomer);
  }
  void removeSelectedCustomer(Map customerData){
    customer.removeWhere((element)=>
      element == customerData["customer_id"]);
  }
}

final selectedCustomerProvider = StateProvider<List<Map>>((ref) => []);