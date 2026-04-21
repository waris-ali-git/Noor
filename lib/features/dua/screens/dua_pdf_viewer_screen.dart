import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../shared/widgets/custom_button.dart';

class DuaPdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const DuaPdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<DuaPdfViewerScreen> createState() => _DuaPdfViewerScreenState();
}

class _DuaPdfViewerScreenState extends State<DuaPdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
            tooltip: 'Bookmarks',
          ),
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: () {
              _pdfViewerController.firstPage();
            },
            tooltip: 'First Page',
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: () {
              _pdfViewerController.lastPage();
            },
            tooltip: 'Last Page',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            SfPdfViewer.network(
              widget.pdfUrl,
              key: _pdfViewerKey,
              controller: _pdfViewerController,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'PDF Loaded - ${details.document.pages.count} pages',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorMessage = details.description;
                  });
                }
              },
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              canShowPaginationDialog: true,
            ),
          
          if (_isLoading && !_hasError)
            const Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading PDF...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          if (_hasError)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load PDF',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    LiquidGlassButton(
                      label: 'Try Again',
                      icon: const Icon(Icons.refresh, size: 18),
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                          _errorMessage = '';
                        });
                        // Triggers a rebuild to reload the PDF
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _pdfViewerController.previousPage(),
                    tooltip: 'Previous Page',
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      _pdfViewerController.zoomLevel =
                          (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
                    },
                    tooltip: 'Zoom In',
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      _pdfViewerController.zoomLevel =
                          (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
                    },
                    tooltip: 'Zoom Out',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _pdfViewerController.nextPage(),
                    tooltip: 'Next Page',
                  ),
                ],
              ),
            ),
    );
  }
}
