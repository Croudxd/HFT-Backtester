# HFT Core: Ultra-Low Latency C++ Trading Engine

A modular, high-frequency trading (HFT) infrastructure built in C++. It utilizes **Shared Memory (IPC)** and **Lock-Free Ring Buffers** to achieve nanosecond-level latency and throughput exceeding 100 million orders per second.

## 🚀 Performance Benchmarks

The system operates at the speed of the CPU cache, effectively removing software overhead.

| Metric | Result | Meaning |
| :--- | :--- | :--- |
| **Tick-to-Trade Latency** | **~26 nanoseconds** | The time it takes for the Strategy to read a price, calculate indicators, and decide to buy. For context, light travels only ~7.8 meters in this time. |
| **Engine Throughput** | **~101 Million Orders/sec** | The number of orders the system can transport and ingest locally. This is significantly faster than any crypto exchange matching engine (which typically handle 100k-500k/sec). |

**Conclusion:** The software stack is no longer the bottleneck. The speed limit is now determined exclusively by the Network Latency (Internet) and the Exchange's API limits.

---

## 🏗 System Architecture

The project is decoupled into independent processes that communicate via **Memory Mapped Files (`/dev/shm`)**. This allows the Strategy and Engine to run on separate CPU cores without context-switching overhead.

```mermaid
graph LR
    A[Market Data Gateway] -- Order IPC --> B[Order-Book]
    B -- Candle IPC --> C[Strategy engine]
    C -- Order IPC  --> B
    B -- Report IPC --> C
    C -- Dashboard IPC --> D[Viewer UI]
