import 'dart:async';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sugam_krishi/keys.dart';
import 'question_answer.dart';

Color scaffoldBackgroundColor = const Color(0xFF343541);
Color cardColor = const Color(0xFF444654);

class chatScreen extends StatefulWidget {
  final String? initialQuery;
  const chatScreen({Key? key, required this.initialQuery}) : super(key: key);

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  String? answer;
  final chatGPT = ChatGpt(apiKey: chatGPT_API_KEY);
  bool loading = false;
  final List<QuestionAnswer> questionAnswers = [];
  late TextEditingController _textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  StreamSubscription<StreamCompletionResponse>? streamSubscription;

  @override
  void initState() {
    focusNode = FocusNode();
    _listScrollController = ScrollController();
    if(widget.initialQuery != null){
      _textEditingController = TextEditingController(text: widget.initialQuery);
      _sendMessage();
    } else {
      _textEditingController = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    _listScrollController.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 1,
        // leading: const BackButton(
        //   color: Colors.black,
        // ),
        automaticallyImplyLeading: true,
        title: Text(
          "AgroAssist",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  controller: _listScrollController,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  physics: BouncingScrollPhysics(),
                  itemCount: questionAnswers.length,
                  itemBuilder: (context, index) {
                    final questionAnswer = questionAnswers[index];
                    final answer = questionAnswer.answer.toString().trim();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //CHAT WIDGET - USER QUERY
                        Material(
                          color: scaffoldBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  // backgroundColor: scaffoldBackgroundColor.withOpacity(0.4),
                                  child: Image.asset(
                                    "assets/farmer_male.png",
                                    scale: 15,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    questionAnswer.question,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (answer.isEmpty && loading)
                          const SpinKitThreeBounce(
                            color: Colors.white,
                            size: 18,
                          )
                        else
                          //CHAT WIDGET
                          Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                            ),
                            color: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipOval(
                                    // backgroundColor: scaffoldBackgroundColor.withOpacity(0.4),
                                    child: Image.asset(
                                      "assets/openai_logo.png",
                                      scale: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      answer,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                ),
              ),
              //TEXT FIELD
              Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: cardColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.white),
                          controller: _textEditingController,
                          onSubmitted: (value) async {
                            _sendMessage();
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: "How can I help you",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            _sendMessage();
                            focusNode.unfocus();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  _sendMessage() async {
    final question = _textEditingController.text;
    scrollListToEND();
    setState(() {
      _textEditingController.clear();
      loading = true;
      questionAnswers.add(
        QuestionAnswer(
          question: question,
          answer: StringBuffer(),
        ),
      );
    });
    final testRequest = CompletionRequest(
      stream: true,
      maxTokens: 4000,
      messages: [Message(role: Role.user.name, content: question)],
    );
    await _streamResponse(testRequest);
    setState(() => loading = false);
  }

  _streamResponse(CompletionRequest request) async {
    streamSubscription?.cancel();
    try {
      final stream = await chatGPT.createChatCompletionStream(request);
      streamSubscription = stream?.listen(
        (event) => setState(
          () {
            if (event.streamMessageEnd) {
              streamSubscription?.cancel();
            } else {
              return questionAnswers.last.answer.write(
                event.choices?.first.delta?.content,
              );
            }
          },
        ),
      );
    } catch (error) {
      setState(() {
        loading = false;
        questionAnswers.last.answer.write("Error");
      });
      print("Error occurred: $error");
    }
  }
}
