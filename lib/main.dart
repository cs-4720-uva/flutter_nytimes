import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nytimes_bestsellers/data/book_database.dart';
import 'package:nytimes_bestsellers/data/bestseller_categories.dart';
import 'package:nytimes_bestsellers/data/ny_times_reader.dart';
import 'package:nytimes_bestsellers/data/book.dart';
import 'package:nytimes_bestsellers/info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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



const _datePreferenceKey = "last_date";

class _MyHomePageState extends State<MyHomePage> {

  final _dateController = TextEditingController();
  final _reader = NYTimesBestSellersReader();
  var _homePageState = CurrentPageState.listView;
  var _bestsellerCategory = BestSellerCategories.combinedFiction;
  Book? _lastBookSelected;

  final bookDb = BookDatabase();

  late Future<List<Book>> bestSellerBooks;

  @override
  void initState() {
    super.initState();
    bestSellerBooks = _reader.getBooks();
    bookDb.initDB();
    _loadPreferences();
  }
  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final storedFormattedDate = preferences.getString(_datePreferenceKey);
    if (storedFormattedDate != null) {
      setState(() {
        _setDate(storedFormattedDate);
      });
    }
  }

  void _setDate(String formattedDate) {
    setState(() {
      _dateController.text = formattedDate;
    });
    _saveFormattedDate(_dateController.text);
  }



  Future<void> _saveFormattedDate(String formattedDate) async{
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(_datePreferenceKey, formattedDate);
  }

  void _toggleView() {
    setState(() {
      if (_homePageState == CurrentPageState.listView) {
        _homePageState = CurrentPageState.savedView;
      } else {
        _homePageState = CurrentPageState.listView;
      }
    });
  }

  void _changeList(BestSellerCategories? newValue) {
    return setState(() {
      if (newValue != null) {
        _bestsellerCategory = newValue;
        bestSellerBooks = _reader.getBooks(list: _bestsellerCategory);
      }
    });
  }

  void _setLastBookSelected(Book? book) {
    setState(() {
      _lastBookSelected = book;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: switch (_homePageState) {
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
            onTap: _toggleView,
            child: switch (_homePageState) {
              CurrentPageState.listView => const Icon(Icons.star, size: 26.0),
              CurrentPageState.savedView =>
                const Icon(Icons.list, size: 26.0),
            },
          ))
      ], // actions
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
    return DropdownButton<BestSellerCategories>(
        value: _bestsellerCategory,
        onChanged: (BestSellerCategories? newValue) {
          _changeList(newValue);
        },
        items: BestSellerCategories.values
            .map((listCategory) => DropdownMenuItem(
                value: listCategory,
                child: Text(listCategory.displayName)
            ))
            .toList());
  }



  Widget datePickerField(BuildContext context) {
    return TextField(
        controller: _dateController,
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
            _setDate(formattedDate);
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
    return Container(
      color: (_lastBookSelected != null && _lastBookSelected == book) ?
          Theme.of(context).colorScheme.primaryContainer :
          Theme.of(context).colorScheme.background
      ,
      child: InkWell(
        onTap: () { _setLastBookSelected(book); },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 46,
                child: bookTitleAndAuthor(book)),
            Expanded(flex: 24,
                child: Column(
                  children: [
                    infoButton(book),
                    saveButton(book),
                  ], // children
                )
            ),
            Expanded(flex: 30, child: bookCoverImage(book))
          ],
        ),
      ),
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
      ])
    );
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
            child: bookTitleAndAuthor(book)
        ),
        Expanded(
            flex: 28,
            child: Column(
              children: [
                infoButton(book),
                deleteButton(book)
              ],
            ),
        ),
        Expanded(
            flex: 30,
            child: bookCoverImage(book))
      ],
    );
  }

  ElevatedButton saveButton(Book book) {
    return ElevatedButton(
      onPressed: () async {
        await bookDb.insertBook(book);
        _setLastBookSelected(book);
      },
      child: const Text("Save"),
    );
  }

  Widget infoButton(Book book) {
    return ElevatedButton(
      onPressed: ()  {
        Navigator.of(context).push(
          MaterialPageRoute( builder:
              (context) => InfoPage(book)
          ),
        );  // Navigator
        _setLastBookSelected(book);
      },
      child: const Text("Info"),
    );
  }

  ElevatedButton deleteButton(Book book) {
    return ElevatedButton(
      onPressed: () async {
        await bookDb.deleteBook(book);
        _setLastBookSelected(null);
      },
      child: const Text(
        "Remove",
        softWrap: false,
      ),
    );
  }
}

Widget bookCoverImage(Book book) {
  return Image.network(
      book.imageUrl,
      height: 100, fit: BoxFit.fitHeight
  );
}

Widget bookTitleAndAuthor(Book book) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(book.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text("by ${book.author}",
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
    ], // children
  );
}