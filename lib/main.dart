import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_olahraga/screens/auth/login_screen.dart';
import 'package:toko_olahraga/screens/auth/register_screen.dart';
import 'package:toko_olahraga/screens/cart/cart_screen.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/utils/constants.dart';
import 'package:toko_olahraga/screens/category/category_products_screen.dart';
import 'package:toko_olahraga/screens/products/product_detail_screen.dart';
import 'package:toko_olahraga/screens/admin/add_product_screen.dart';
import 'package:toko_olahraga/screens/admin/products_management_screen.dart';
import 'package:toko_olahraga/screens/home/home_screen.dart'; // Import HomeScreen
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ProductsProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasData) {
              // Panggil konstruktor HomeScreen dengan `const` jika tidak ada parameter yang berubah
              return const HomeScreen(); // Tidak perlu key jika sudah const
            }
            return const LoginScreen();
          },
        ),
        routes: {
          '/cart': (ctx) => const CartScreen(),
          '/register': (ctx) => const RegisterScreen(),
          // Panggil konstruktor HomeScreen dengan `const`
          '/home': (ctx) => const HomeScreen(),
          CategoryProductsScreen.routeName: (ctx) => const CategoryProductsScreen(
            categoryTitle: '',
            categoryName: '',
          ),
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          AddProductScreen.routeName: (ctx) => const AddProductScreen(),
          ProductsManagementScreen.routeName: (ctx) => const ProductsManagementScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}