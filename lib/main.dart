import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nytimes_bestsellers/data/book_database.dart';
import 'package:nytimes_bestsellers/data/ny_times_lists.dart';
import 'package:nytimes_bestsellers/data/ny_times_reader.dart';
import 'package:nytimes_bestsellers/data/book.dart';

Future main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum CurrentPageState { listView, savedView }

class _MyHomePageState extends State<MyHomePage> {
  var dateController = TextEditingController();
  final reader = NYTimesReader();
  var homePageState = CurrentPageState.listView;
  var bookListSelection = NYTimesList.combinedFiction;

  final bookDb = BookDatabase();

  late Future<List<Book>> bestSellerBooks;

  @override
  void initState() {
    super.initState();
    bestSellerBooks = reader.getBooks();
    bookDb.initDB();
  }

  void _setDate(String formattedDate) {
    dateController.text = formattedDate;
  }

  void _toggleView() {
    if (homePageState == CurrentPageState.listView) {
      homePageState = CurrentPageState.savedView;
    } else {
      homePageState = CurrentPageState.listView;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: switch (homePageState) {
        CurrentPageState.listView => listViewBody(context),
        CurrentPageState.savedView => savedViewBody(context),
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("NY Times Best-Sellers"),
      actions: [
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _toggleView();
                });
              },
              child: switch (homePageState) {
                CurrentPageState.listView =>
                  const Icon(Icons.star, size: 26.0),
                CurrentPageState.savedView =>
                  const Icon(Icons.list, size: 26.0),
              },
            )
        )
      ],
    );
  }

  Widget listViewBody(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          listSelector(context),
          datePickerField(context),
          bestSellerList(context),
        ],
      ),
    );
  }

  Widget listSelector(BuildContext context) {
    return DropdownButton<NYTimesList>(
        value: bookListSelection,
        onChanged: (NYTimesList? newValue) {
          setState(() {
            if (newValue != null) {
              bookListSelection = newValue;
              bestSellerBooks = reader.getBooks(list: bookListSelection);
            }
          });
        },
        items: NYTimesList.values
            .map((listCategory) =>
                DropdownMenuItem(
                    value: listCategory,
                    child: Text(listCategory.displayName)))
            .toList());
  }

  Widget datePickerField(BuildContext context) {
    return TextField(
        controller: dateController,
        decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today), labelText: "Select Date"),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2010),
              lastDate: DateTime(DateTime.now().year + 1));
          if (pickedDate != null) {
            String formattedDate = DateFormat("MM-dd-yyyy").format(pickedDate);
            setState(() {
              _setDate(formattedDate);
            });
          }
        });
  }

  Widget bestSellerList(BuildContext context) {
    return FutureBuilder(
        future: bestSellerBooks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return bestSellerListView(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        });
  }

  Widget bestSellerListView(List<Book> books) {
    final ScrollController bestSellerScrollController = ScrollController();

    return Flexible(
      child: Scrollbar(
        controller: bestSellerScrollController,
        child: ListView.separated(
          controller: bestSellerScrollController,
          padding: const EdgeInsets.all(8),
          itemCount: books.length,
          itemBuilder: (BuildContext context, int index) {
            return bestSellerBookContainer(books[index], index + 1);
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
    );
  }

  Widget bestSellerBookContainer(Book book, int rank) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$rank. ${book.title}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "by ${book.author}",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            )
        ),
        Expanded(
            flex: 24,
            child: ElevatedButton(
              onPressed: () async {
                await bookDb.insertBook(book);
                setState(() {});
              },
              child: const Text("Save"),
            )
        ),
        Expanded(
            flex: 30,
            child: Image.network(
                book.imageUrl,
                height: 100, fit: BoxFit.fitHeight
            )
        )
      ],
    );
  }

  Widget savedViewBody(BuildContext context) {
    return Center(
        child: Column(children: <Widget>[
      FutureBuilder(
        future: bookDb.getAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return savedListView(snapshot.data!);
          }
        },
      )
    ]));
  }

  Widget savedListView(List<Book> books) {
    final ScrollController bestSellerScrollController = ScrollController();

    return Flexible(
      child: Scrollbar(
        controller: bestSellerScrollController,
        child: ListView.separated(
          controller: bestSellerScrollController,
          padding: const EdgeInsets.all(8),
          itemCount: books.length,
          itemBuilder: (BuildContext context, int index) {
            return savedBookContainer(books[index]);
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),
      ),
    );
  }

  Widget savedBookContainer(Book book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "by ${book.author}",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            )),
        Expanded(
            flex: 28,
            child: ElevatedButton(
              onPressed: () async {
                await bookDb.deleteBook(book);
                setState(() {});
              },
              child: const Text(
                "Remove",
                softWrap: false,
              ),
            )),
        Expanded(
            flex: 30,
            child: Image.network(book.imageUrl,
                height: 100, fit: BoxFit.fitHeight))
      ],
    );
  }
}
