import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:travel_app/components/alert_date.dart';
import 'package:travel_app/components/custom_button.dart';

import 'package:travel_app/components/custom_field.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/home/search_option_controller.dart';
import 'package:travel_app/controllers/home/search_results_controller.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/views/home/search_results_screen.dart';

class SearchOptionScreen extends GetWidget<SearchOptionController> {
  const SearchOptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomText(
          text: "Search".tr,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        // leading: BuildArrowBackIcon(),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: GetBuilder<SearchOptionController>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: " " + "City".tr,
                  color: k_fontGray,
                ),
                SizedBox(height: 10),
                CustomField(
                  hint: "City".tr,
                  fillColor: k_fieldGray,
                  controller: controller.city,
                  prefixIcon: Icon(LineIcons.search),
                  hintText: '',
                  readOnly: false,
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: " " + "Start date".tr,
                            color: k_fontGray,
                          ),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDate(
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      DateRangeContoller:
                                          controller.dateController,
                                      onPressed: () {
                                        controller.onSelectDate();
                                        controller.desplay();
                                      },
                                    );
                                  },
                                );
                              },
                              child: CustomField(
                                enabled: false,
                                hint: controller.checkIn.text,
                                fillColor: k_fieldGray, hintText: '',
                                readOnly: false,
                                // prefixIcon: Icon(LineIcons.calendar),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: " " + "Return date".tr,
                            color: k_fontGray,
                          ),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDate(
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      DateRangeContoller:
                                          controller.dateController,
                                      onPressed: () {
                                        controller.onSelectDate();
                                        controller.desplay();
                                      },
                                    );
                                  },
                                );
                              },
                              child: CustomField(
                                enabled: false,
                                hint: controller.checkOut.text,
                                fillColor: k_fieldGray, hintText: '',
                                readOnly: false,
                                // prefixIcon: Icon(LineIcons.calendar),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: "Search".tr,
                  onPressed: () async {
                    Get.to(() => SearchResultsScreen(
                          city: controller.city.text,
                          checkIn: controller.checkInDateTime!,
                          checkOut: controller.checkOutDateTime!,
                        ));
                    Get.find<SearchResultsController>().searching(
                      city: controller.city.text,
                      checkIn: controller.checkInDateTime,
                      checkOut: controller.checkOutDateTime,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BuildItem extends StatelessWidget {
  const _BuildItem({
    Key? key,
    this.increaseFunction,
    this.decreaseFunction,
    required this.title,
    required this.count,
  }) : super(key: key);
  final void Function()? increaseFunction;
  final void Function()? decreaseFunction;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          color: k_fontGray,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: decreaseFunction,
              child: Container(
                width: 45,
                height: 49,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: k_fontGray,
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  color: k_primaryColor,
                  size: 20,
                ),
              ),
            ),
            CustomText(
              text: count.toString(),
              fontSize: 18,
            ),
            GestureDetector(
              onTap: increaseFunction,
              child: Container(
                width: 45,
                height: 49,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: k_fontGray,
                  ),
                ),
                child: Icon(
                  LineIcons.plus,
                  color: k_primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
