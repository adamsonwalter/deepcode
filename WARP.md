# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

DeepCode is an open-source AI research engine that transforms research papers and natural language requirements into production-ready code through multi-agent orchestration. It uses the Model Context Protocol (MCP) for seamless tool integration and provides both CLI and web interfaces.

## Common Development Commands

### Installation and Setup
```bash
# Development installation from source
git clone https://github.com/HKUDS/DeepCode.git
cd DeepCode/

# Using UV (recommended for development)
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv --python=3.13
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
uv pip install -r requirements.txt

# Using traditional pip
pip install -r requirements.txt

# Direct installation from PyPI
pip install deepcode-hku
```

### Configuration
```bash
# Configure API keys in mcp_agent.secrets.yaml:
# - openai: api_key, base_url (for OpenAI/custom endpoints)  
# - anthropic: api_key (for Claude models)

# Configure search API keys in mcp_agent.config.yaml (optional):
# - BRAVE_API_KEY for web search functionality
# - BOCHA_API_KEY for alternative search

# Update document segmentation settings:
# - enabled: true/false
# - size_threshold_chars: 50000 (default)
```

### Running the Application
```bash
# Web interface (recommended)
deepcode                           # Installed package
# OR
streamlit run ui/streamlit_app.py  # From source
# Access at http://localhost:8501

# CLI interface (advanced users)
python cli/main_cli.py             # Interactive mode
python cli/main_cli.py --file paper.pdf        # Process specific file
python cli/main_cli.py --url https://...       # Process URL
python cli/main_cli.py --chat "Build a web app..." # Chat requirements
python cli/main_cli.py --optimized             # Fast mode (skip indexing)
```

### Development Workflow
```bash
# Clean cache files
find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null
find . -name "*.pyc" -delete 2>/dev/null

# Install in development mode
pip install -e .

# Package and distribute
python setup.py sdist bdist_wheel
```

## Architecture Overview

### Core Components

**Multi-Agent Orchestration Engine** (`workflows/agent_orchestration_engine.py`)
- Central orchestration system coordinating 6+ specialized AI agents
- Handles document processing → reference analysis → code generation pipeline
- Supports two modes: comprehensive (with indexing) and optimized (fast)
- Main entry point: `execute_multi_agent_research_pipeline()`

**MCP (Model Context Protocol) Integration** (`mcp_agent.config.yaml`)
- Standardized protocol for AI agent-tool communication
- 9+ integrated MCP servers: filesystem, web search, GitHub downloader, code implementation, etc.
- Extensible tool framework for adding new capabilities
- Dynamic server configuration with environment variables

**User Interfaces**
- **Web UI** (`ui/`): Streamlit-based interface with drag-and-drop file upload
- **CLI** (`cli/`): Terminal interface with interactive menus and direct command processing
- Both interfaces share the same underlying workflow adapter

### Agent Architecture

The system employs 6 specialized agents:
1. **Central Orchestrating Agent**: Strategic decision-making and workflow coordination
2. **Intent Understanding Agent**: Semantic analysis and requirement parsing
3. **Document Parsing Agent**: Research paper and technical document processing
4. **Code Planning Agent**: Architecture design and technology stack optimization
5. **Code Reference Mining Agent**: Repository discovery and compatibility analysis
6. **Code Generation Agent**: Implementation synthesis with testing and documentation

### Data Flow

```
Input (Papers/URLs/Chat) → Document Processing → Reference Analysis → 
Code Planning → Repository Mining → Code Indexing → Implementation Generation → 
Output (Complete Codebase + Tests + Documentation)
```

### Key Technologies

- **Python 3.9+**: Core runtime environment
- **Streamlit**: Web interface framework
- **Asyncio**: Asynchronous processing for multi-agent coordination
- **MCP Servers**: Node.js-based tool servers for external integrations
- **Document Processing**: PDF, DOCX, HTML, TXT, MD support with intelligent segmentation
- **Code Generation**: Multi-language support with AST analysis and testing

## Configuration Files

### `mcp_agent.config.yaml`
Primary configuration file controlling:
- MCP server definitions and connection parameters
- Search engine selection (Brave vs Bocha-MCP)
- Document segmentation thresholds and behavior
- Pipeline mode selection (traditional vs segmented)
- Logging and progress display settings

### `mcp_agent.secrets.yaml`
Secure credential storage for:
- OpenAI/Anthropic API keys and endpoints
- Search service API keys
- Custom model endpoints and authentication

### `requirements.txt`
Core dependencies including:
- `mcp-agent`: Model Context Protocol client
- `streamlit`: Web interface framework
- `anthropic`: Claude API integration
- `docling`: Advanced document processing
- `aiofiles`, `aiohttp`: Async I/O capabilities

## Working with the Codebase

### File Organization
- `cli/`: Command-line interface and workflow adapters
- `ui/`: Streamlit web interface components
- `workflows/`: Core agent orchestration and pipeline logic
- `tools/`: MCP server implementations and utility functions
- `utils/`: Shared utilities for file processing and logging
- `config/`: Tool definitions and configuration schemas
- `assets/`: Static assets and branding
- `prompts/`: AI agent prompt templates

### Development Patterns

**Async/Await Throughout**: All core workflows use asyncio for concurrent agent execution

**MCP Tool Integration**: New tools follow the MCP server pattern in `tools/` directory

**Configuration-Driven**: Behavior controlled via YAML configuration rather than hardcoded values

**Modular Agent Design**: Each agent is self-contained with clear input/output contracts

**Progress Callbacks**: Real-time progress reporting through callback mechanisms

### Adding New Features

1. **New MCP Tools**: Create server script in `tools/`, add configuration to `mcp_agent.config.yaml`
2. **UI Extensions**: Add components to `ui/`, update layout and handlers
3. **Agent Extensions**: Modify orchestration engine or create new specialized agents
4. **Document Types**: Extend processing in document segmentation server

### Important Considerations

- **Token Limits**: Document segmentation automatically handles large papers exceeding LLM context windows
- **API Costs**: Comprehensive mode uses more API calls; optimized mode reduces costs
- **System Requirements**: LibreOffice needed for Office document conversion (optional)
- **Workspace Management**: Automatic `deepcode_lab/` directory creation for project isolation
