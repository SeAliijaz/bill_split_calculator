import 'package:bill_split_calculator/Components/custom_drawer.dart';
import 'package:bill_split_calculator/Constants/constants.dart';
import 'package:bill_split_calculator/Custom_Widgets/reusable_formfield.dart';
import 'package:bill_split_calculator/Models/split_data_model.dart';
import 'package:bill_split_calculator/Screen/summary_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ///vars
  double tipPercentage = 0.0;
  double discountPercentage = 0.0;
  int numberOfPersons = 1;
  int maxNumberOfPersons = 100;
  double totalBill = 0.0;
  bool isButtonEnabled = false;

  ///Controllers
  TextEditingController billController = TextEditingController();
  TextEditingController deliveryChargesController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  List<TextEditingController> personNameControllers = [];
  List<TextEditingController> personAmountPaidControllers = [];

  ///initState
  @override
  void initState() {
    super.initState();
    personNameControllers =
        List.generate(numberOfPersons, (_) => TextEditingController());
    personAmountPaidControllers =
        List.generate(numberOfPersons, (_) => TextEditingController());
  }

  ///dispose
  @override
  void dispose() {
    billController.dispose();
    deliveryChargesController.dispose();
    discountController.dispose();
    for (var controller in personNameControllers) {
      controller.dispose();
    }
    for (var controller in personAmountPaidControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  ///updateNumberOfPersons
  void updateNumberOfPersons(int value) {
    setState(() {
      numberOfPersons = value;
      personNameControllers =
          List.generate(value, (_) => TextEditingController());
      personAmountPaidControllers =
          List.generate(value, (_) => TextEditingController());
    });
    updateButtonState();
  }

  ///areFieldsFilled
  bool areFieldsFilled() {
    if (billController.text.isEmpty ||
        deliveryChargesController.text.isEmpty ||
        discountController.text.isEmpty ||
        personNameControllers.any((controller) => controller.text.isEmpty) ||
        personAmountPaidControllers
            .any((controller) => controller.text.isEmpty)) {
      return false;
    }
    return true;
  }

  ///updateButtonState
  void updateButtonState() {
    setState(() {
      isButtonEnabled = areFieldsFilled();
    });
  }

  ///splitBill
  void splitBill() {
    if (areFieldsFilled()) {
      double totalBill = double.tryParse(billController.text) ?? 0.0;
      double deliveryCharges =
          double.tryParse(deliveryChargesController.text) ?? 0.0;
      double discount = double.tryParse(discountController.text) ?? 0.0;
      double finalBill =
          calculateFinalBill(totalBill, deliveryCharges, discount);
      List<SplitData> splitDataList = [];
      for (int i = 0; i < numberOfPersons; i++) {
        String personName = personNameControllers[i].text;
        double amountPaid =
            double.tryParse(personAmountPaidControllers[i].text) ?? 0.0;
        double splitAmount = calculateSplitAmount(finalBill, amountPaid);
        SplitData splitData = SplitData(
            personName: personName,
            amountPaid: amountPaid,
            totalBill: finalBill,
            splitAmount: splitAmount);
        splitDataList.add(splitData);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(splitDataList: splitDataList),
        ),
      );
    } else {
      AppUtilities.showDialogMessage(
          context, "Validation Error", "Please fill all required fields.");
    }
  }

  ///  Widget build
  @override
  Widget build(BuildContext context) {
    double totalBill = double.tryParse(billController.text) ?? 0.0;
    double deliveryCharges =
        double.tryParse(deliveryChargesController.text) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double finalBill = calculateFinalBill(totalBill, deliveryCharges, discount);
    return Scaffold(
      ///AppBar
      appBar: AppBar(
        title: const Text('Bill Split Calculator'),
        centerTitle: true,
      ),

      ///Drawer
      drawer: CustomDrawer(),

      ///bottomNavigationBar
      bottomNavigationBar: SizedBox(
        height: 65.5,
        child: ElevatedButton(
          onPressed: isButtonEnabled ? splitBill : null,
          child: Text(isButtonEnabled
              ? 'Split Bill'
              : "Please fill all required fields."),
        ),
      ),

      ///BODY
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            CustomTextField(
              textTitle: 'Bill Amount',
              hintText: 'Enter the bill amount',
              prefixIcon: Icons.attach_money_outlined,
              textEditingController: billController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the bill amount';
                }
                return null;
              },
              onChanged: (value) {
                updateButtonState();
              },
            ),
            CustomTextField(
              textTitle: 'Delivery Charges',
              hintText: 'Enter the delivery charges',
              prefixIcon: Icons.local_shipping_outlined,
              textEditingController: deliveryChargesController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the delivery charges';
                }
                return null;
              },
              onChanged: (value) {
                updateButtonState();
              },
            ),
            CustomTextField(
              textTitle: 'Discount',
              hintText: 'Enter the discount',
              prefixIcon: Icons.local_offer_outlined,
              textEditingController: discountController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the discount';
                }
                return null;
              },
              onChanged: (value) {
                updateButtonState();
              },
            ),
            CustomTextField(
              textTitle: 'Number of Persons',
              hintText: 'Enter the number of persons',
              isInstructionNeeded: true,
              prefixIcon: Icons.person_outline,
              textEditingController: TextEditingController(),
              onChanged: (value) {
                int numberOfPersons = int.tryParse(value) ?? 0;
                updateNumberOfPersons(numberOfPersons);
              },
              validator: (value) {
                return null;
              },
            ),
            ListTile(
              title: Text(
                'Total Bill:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "\$${finalBill.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ///List TO Generate Persons lists
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: numberOfPersons,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CustomTextField(
                      textTitle: 'Person ${index + 1} Name',
                      hintText: 'Enter the name of person ${index + 1}',
                      prefixIcon: Icons.person_outline,
                      textEditingController: personNameControllers[index],
                      onChanged: (value) {
                        updateButtonState();
                      },
                      validator: (value) {
                        return null;
                      },
                    ),
                    CustomTextField(
                      textTitle: 'Amount Paid',
                      hintText: 'Enter the amount paid by person ${index + 1}',
                      prefixIcon: Icons.attach_money_outlined,
                      textEditingController: personAmountPaidControllers[index],
                      onChanged: (value) {
                        updateButtonState();
                      },
                      validator: (value) {
                        return null;
                      },
                    ),
                  ],
                );
              },
              separatorBuilder: (c, i) {
                return Divider();
              },
            ),
          ],
        ),
      ),
    );
  }

  double calculateSplitAmount(double totalBill, double amountPaid) {
    double totalAmountPaid = personAmountPaidControllers.fold(
      0.0,
      (previousValue, controller) =>
          previousValue + (double.tryParse(controller.text) ?? 0.0),
    );
    double totalRemainingAmount = totalBill - totalAmountPaid;
    double splitAmount = (totalRemainingAmount / numberOfPersons) + amountPaid;
    return splitAmount;
  }

  double calculateFinalBill(
      double totalBill, double deliveryCharges, double discount) {
    double tipAmount = totalBill * (tipPercentage / 100);
    double finalBill = totalBill + deliveryCharges - discount + tipAmount;
    return finalBill;
  }
}
