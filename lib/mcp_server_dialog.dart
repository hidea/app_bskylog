import 'package:flutter/material.dart';
import 'model.dart';

Future<void> showMcpServerDialog(BuildContext dialogContext, Model model) async {
  final portController = TextEditingController(text: model.mcpServerPort.toString());

  // Always warn when starting, switch immediately when stopping
  if (model.mcpServerState == McpServerState.stopped) {
    await showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('MCP Server Notice'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'This will start the MCP server and expose your Bluesky post logs to external access. Please confirm you understand the risks before proceeding.',
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Spacer(),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
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
      ),
    );
  } else {
    await model.toggleMcpServer();
  }
}
