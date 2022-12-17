import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ledger/pages/accounts_page.dart';
import 'package:ledger/pages/budgets_page.dart';
import 'package:ledger/pages/transactions_page.dart';
import 'package:rxdart/rxdart.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static final List<NavBarItem> pages = [
      NavBarItem('Transactions', TransactionsPage(), Icons.receipt_long),
      NavBarItem('Budgets', BudgetsPage(), Icons.savings),
      NavBarItem('Accounts', AccountsPage(), Icons.account_balance),
  ];

  static final pageController = PageController(initialPage: 0);
  static final mainPageState = GetIt.instance.get<MainPageState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<int>(
          stream: mainPageState.currentIndexStream,
          builder: (context, snapshot) {
            return Text(pages[snapshot.data ?? 0].pageName.toString());
          }
        ),
      ),

      body: PageView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) => pages[index].page,
        onPageChanged: onPageChanged, 
        controller: pageController,
      ),
      
      bottomNavigationBar: StreamBuilder<int>(
        stream: mainPageState.currentIndexStream,
        builder: (context, snapshot) {
          return BottomNavigationBar(
            currentIndex: snapshot.data ?? 0,
            onTap: (index) => pageController.animateToPage(index,
                duration: const Duration(milliseconds: 500), curve: Curves.ease),
            items: pages,
          );
        }
      ),
    );
  }

  void onPageChanged(int newIndex) {
    pages[mainPageState.currentIndex].page.unview();
    pages[newIndex].page.view();
    mainPageState.update(newIndex);
  }
}

class MainPageState {
  final _currentIndex = BehaviorSubject<int>.seeded(0);

  ValueStream<int> get currentIndexStream => _currentIndex.stream;
  
  int get currentIndex => _currentIndex.value;

  update(int newIndex) {
    _currentIndex.add(newIndex);
  }
}

class NavBarItem<T extends NavPage> extends BottomNavigationBarItem {
  final String pageName;
  final NavPage page;
  final IconData navPageIcon;

  NavBarItem(this.pageName, this.page, this.navPageIcon)
      : super(icon: Icon(navPageIcon), label: pageName);

}

abstract class NavPage extends StatelessWidget {
  final isInView = BehaviorSubject<bool>.seeded(false);

  NavPage({super.key});

  void view() {
    isInView.add(true);
  }

  void unview() {
    isInView.add(false);
  }
}