import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nytimes_bestsellers/data/ny_times_reader.dart';
import 'package:nytimes_bestsellers/data/book.dart';

void main() {
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

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController dateController = TextEditingController();
  NYTimesReader reader = NYTimesReader();
  late Future<List<Book>> books;

  @override
  void initState() {
    super.initState();
    books = reader.getBooks();
  }

  void _setDate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            datePickerField(context),
            FutureBuilder(
                future: books,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return getBooksList(snapshot.data!);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                }),
          ],
        ),
      ),
    );
  }

  TextField datePickerField(BuildContext context) {
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
              dateController.text = formattedDate;
            });
          }
        });
  }

  Widget getBooksList(List<Book> books) {
    final ScrollController _scrollController = ScrollController();

    return Flexible(
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: books.length,
          itemBuilder: (BuildContext context, int index) {
            return bookContainer(books[index]);
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        ),
      ),
    );
  }

  Widget bookContainer(Book book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${book.rank}. "),
            Text(book.title),
            Text(book.author),
          ],
        ),
        Image.network(
          book.imageUrl,
          height: 100,
        )
      ],
    );
  }
}
