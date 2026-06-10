import 'package:flutter/material.dart';
import 'model.dart';

Future<void> showMcpServerDialog(BuildContext dialogContext, Model model) async {
  final portController = TextEditingController(text: model.mcpServerPort.toString());

  // Always warn when starting, switch immediately when stopping
  if (model.mcpServerState == McpServerState.stopped) {
    await showDialog(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            portController.addListener(() {
              if (context.mounted) setState(() {});
            });
            return AlertDialog(
              title: SelectionArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('MCP Server Notice'),
                  ],
                ),
              ),
              content: SelectionArea(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This will start the MCP server and expose your Bluesky post logs to external access. Please confirm you understand the risks before proceeding.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Register URL:',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'http://localhost:${portController.text.isEmpty ? model.mcpServerPort : portController.text}/sse',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Courier',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Port:'),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            height: 28,
                            child: TextField(
                              controller: portController,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  child: const Text('Confirm'),
                  onPressed: () async {
                    final port = int.tryParse(portController.text);
                    if (port != null && port > 0 && port < 65536) {
                      model.setMcpServerPort(port);
                    }
                    Navigator.of(context).pop();
                    await model.toggleMcpServer();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  } else {
    await model.toggleMcpServer();
  }
}
