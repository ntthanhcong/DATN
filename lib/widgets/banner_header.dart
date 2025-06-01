import 'package:flutter/material.dart';

class BannerHeader extends StatelessWidget {
  const BannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Xe giường nằm cao cấp Út Ngân',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            'Tuyến: Krông Năng - Đắk Lắk - Gia Lai - Bình Định - Quảng Ngãi - Quảng Nam - Đà Nẵng - Huế',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          SizedBox(height: 2),
          Text(
            'Tổng đài đặt vé: 0708.819.819 - 0706.819.819',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
