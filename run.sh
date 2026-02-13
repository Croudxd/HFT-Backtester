#!/bin/bash
set -e

mkdir -p logs

git submodule update --init --recursive

submodules=("order-book" "strategy")
for dir in "${submodules[@]}"; do
    if [ -d "$dir" ]; then
        pushd "$dir" > /dev/null
        mkdir -p build
        cd build
        cmake ..
        make -j$(nproc)
        popd > /dev/null
    fi
done

if [ -d "bitfinex" ]; then
    pushd "bitfinex" > /dev/null
    cargo build --release
    popd > /dev/null
fi


rm -f /dev/shm/hft_*
pkill -f "build/engine" || true
pkill -f "build/strategy" || true
pkill -f "release/bitfinex" || true

trap 'kill $(jobs -p)' EXIT

nohup ./order-book/build/order-book > logs/engine.log 2>&1 &
sleep 0.5

if [ -f "./bitfinex/target/release/bitfinex" ]; then
    echo "Starting Gateway..."
    nohup cargo run > logs/gateway.log 2>&1 &
    sleep 0.5
fi

echo "Starting Strategy..."
nohup ./strategy/build/strategy > logs/strategy.log 2>&1 &
sleep 0.5

echo "Launching Viewer..."
./strategy/build/viewer
