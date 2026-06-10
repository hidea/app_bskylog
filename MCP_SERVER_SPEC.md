# bskylog MCP Server Specification

## 1. Overview
`bskylog` includes a built-in MCP (Model Context Protocol) server that allows external AI clients to explore and analyze post logs retrieved from Bluesky. 
The server utilizes a bidirectional communication protocol based on SSE (Server-Sent Events).

## 2. Connection and Communication

### 2.1 Connection Settings
- **Endpoint**: `http://localhost:<port>/sse`
- **Default Port**: `8080` (customizable in the app UI)
- **Transport**: Hybrid SSE (GET) and HTTP (POST)
  - **Receiving**: Establish a stream via a GET request to `/sse`.
  - **Sending**: Send messages via a POST request to `/sse?sessionId=<id>`.

### 2.2 Protocol
- **JSON-RPC 2.0**: All messages are exchanged in JSON-RPC 2.0 format.
- **SSE Sessions**: Maintains stateful communication using a `sessionId` issued upon connection.

## 3. Provided Tools
The following tools are available for AI clients to call.

### 3.1 get_recent_posts
Retrieves the most recent post logs in descending chronological order.
- **Parameters (inputSchema)**:
  - `limit` (integer, default: 3): Number of posts to fetch.

### 3.2 search_posts
Searches for posts using keywords, date ranges, or regex patterns.
- **Parameters (inputSchema)**:
  - `keyword` (string): Search keyword.
  - `startDate` (string, ISO8601): Start of the search date range (optional).
  - `endDate` (string, ISO8601): End of the search date range (optional).
  - `pattern` (string): Regular expression pattern for searching (optional).
  - `limit` (integer, default: 10): Maximum number of results to retrieve.

### 3.3 get_user_activity
Retrieves post logs related to a specific user.
- **Parameters (inputSchema)**:
  - `userId` (string, **required**): Target DID or handle.
  - `limit` (integer, default: 10): Number of items to fetch.

### 3.4 get_monthly_activity_summary
Retrieves a monthly activity summary (post count trends, top hashtags) for a specific year.
- **Parameters (inputSchema)**:
  - `year` (integer, **required**): The target year (e.g., 2025).

## 4. UI Integration and Configuration
- **Dynamic Port Setting**: Users can specify the port number when starting the server.
- **Configuration Persistence**: The last used port number is saved in `SharedPreferences` and automatically restored on the next launch.
- **Status Monitoring**: The server's running state (Stopped/Running) can be monitored via the icon color in the app's Navigation Drawer.

---
**Last Updated**: 2026-02-24  
**MCP Specification Version**: 2025-11-25
