

import 'package:riverpod/riverpod.dart';

class SelectedCustomerModels {
  List customer = [];
  SelectedCustomerModels({List? customer});
  
  void addSelectedCustomer(Map selectedCustomer) {
    customer.add(selectedCustomer);
  }
  void removSelectedCustomer(Map customerData){
    customer.removeWhere((element)=>
      element["customer_name"] == customerData["customer_name"]);
  }
}

final selectedCustomerProvider = StateProvider<SelectedCustomerModels>((ref) => SelectedCustomerModels());