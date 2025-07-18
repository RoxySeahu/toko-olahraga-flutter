import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toko_olahraga/firebase_options.dart'; 
import 'package:toko_olahraga/providers/product_provider.dart';
import 'package:toko_olahraga/providers/cart_provider.dart';
import 'package:toko_olahraga/screens/home/home_screen.dart';
import 'package:toko_olahraga/screens/products/product_detail_screen.dart';
import 'package:toko_olahraga/screens/cart/cart_screen.dart';
import 'package:toko_olahraga/screens/admin/products_management_screen.dart';
import 'package:toko_olahraga/screens/admin/add_product_screen.dart';
import 'package:toko_olahraga/screens/category/category_products_screen.dart';
import 'package:toko_olahraga/screens/auth/login_screen.dart';
import 'package:toko_olahraga/screens/auth/register_screen.dart';
import 'package:toko_olahraga/screens/checkout/checkout_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_olahraga/utils/constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color.fromARGB(255, 111, 128, 141)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            labelStyle: TextStyle(color: Colors.grey.shade700),
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.all(8.0),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              if (kDebugMode) {
                print('DEBUG: Auth state di main.dart: Menunggu...');
              }
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasData) {
              if (kDebugMode) {
                print('DEBUG: Auth state di main.dart: Pengguna login: ${userSnapshot.data!.uid}');
              }
              return const HomeScreen();
            }
            if (kDebugMode) {
              print('DEBUG: Auth state di main.dart: Tidak ada pengguna login. Mengarahkan ke LoginScreen.');
            }
            return const LoginScreen();
          },
        ),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),

          // Pastikan rute ini benar. Jika LoginScreen Anda menggunakan '/login', ubah ini.
          '/register': (ctx) => const RegisterScreen(),
          '/login': (ctx) => const LoginScreen(), // Tambahkan ini jika Anda punya LoginScreen terpisah
          '/home': (ctx) => const HomeScreen(), // Ini adalah rute eksplisit ke HomeScreen
          CheckoutScreen.routeName: (ctx) => const CheckoutScreen(),

          CategoryProductsScreen.routeName: (ctx) {
            final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, String>?;
            return CategoryProductsScreen(
              categoryName: args?['categoryName'] ?? '',
              categoryTitle: args?['categoryTitle'] ?? '',
            );
          },

          ProductsManagementScreen.routeName: (ctx) => const ProductsManagementScreen(),
          AddProductScreen.routeName: (ctx) => const AddProductScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}