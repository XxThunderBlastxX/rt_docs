import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../colors.dart';
import '../common/widgets/loader.dart';
import '../models/document_model.dart';
import '../models/error_model.dart';
import '../repository/auth_repository.dart';
import '../repository/document_repository.dart';
import '../repository/socket_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  ConsumerState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Text');

  quill.QuillController? _quillController;

  ErrorModel? errorModel;

  SocketRepository socketRepository = SocketRepository();

  void updateTitle(WidgetRef ref, String title) {
    final uProvider = ref.read(userProvider);
    ref.read(documentRepoProvider).updateDocumentTitle(
          token: uProvider!.token,
          id: widget.id,
          title: title,
        );
  }

  void fetchDocData() async {
    errorModel = await ref
        .read(documentRepoProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      setState(() {
        titleController.text = (errorModel!.data as DocumentModel).title;
        _quillController = quill.QuillController(
          selection: const TextSelection.collapsed(offset: 0),
          document: errorModel!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  quill.Delta.fromJson(errorModel!.data.content),
                ),
        );
      });
    }
    _quillController!.document.changes.listen((event) {
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.item2,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDocData();
    socketRepository.joinRoom(widget.id);
    socketRepository.changeListener((data) {
      _quillController?.compose(
        quill.Delta.fromJson(data['delta']),
        _quillController?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.REMOTE,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quillController == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.lock,
                size: 18,
              ),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/doc_img.png',
                height: 40,
              ),
              const SizedBox(width: 10.0),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlueColor),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  onSubmitted: (value) => updateTitle(ref, value),
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: kGreyColor,
                width: 0.1,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillToolbar.basic(controller: _quillController!),
            const SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: quill.QuillEditor.basic(
                      controller: _quillController!,
                      readOnly: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
