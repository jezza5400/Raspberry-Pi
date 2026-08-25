# Overclocking Raspberry Pi 4B and 5B

This guide provides instructions on how to overclock your Raspberry Pi 4B and 5B models for improved performance. Please note that overclocking may void your warranty and can potentially damage your device if not done carefully.

## Prerequisites

- A Raspberry Pi 4B or 5B
- Adequate cooling solution (heatsink, fan, or both)
- Latest Raspberry Pi OS installed
- Basic knowledge of terminal commands

## Raspberry Pi 4B Overclocking

1. Open the config file:

```bash
sudo nano /boot/firmware/config.txt
```

2. Add the following lines at the end of the file:

```conf
over_voltage=6 # Voltage boost (default is 0)
arm_freq=2000 # CPU to 2.0 GHz (default is 1.5 GHz)
gpu_freq=750 # GPU to 750 MHz (default is 500 MHz)
```

3. Save and exit the file (Ctrl+X, then Y, then Enter).

4. Reboot your Raspberry Pi:

```bash
sudo reboot
```

## Raspberry Pi 5B Overclocking

1. Open the config file:

```bash
sudo nano /boot/firmware/config.txt
```

2. Add the following lines at the end of the file:

```conf
over_voltage_delta=50000 # Adds ~0.05V to support higher frequencies
arm_freq=3000 # CPU to 3.0 GHz (default is 2.4 GHz)
gpu_freq=1000 # GPU to 1.0 GHz (default ~910 MHz)
```

3. Save and exit the file (Ctrl+X, then Y, then Enter).

4. Reboot your Raspberry Pi:

```bash
sudo reboot
```

## Monitoring and Stability

To monitor your Raspberry Pi's performance and ensure stability:

1. Install stress-testing tools:

```bash
sudo apt install stress
```

2. Monitor CPU clock speed:

```bash
watch -n 1 vcgencmd measure_clock arm
```

3. Run a stress test:

```bash
stress --cpu 4 --timeout 60
```

4. Monitor temperature:

```bash
vcgencmd measure_temp
```

## Troubleshooting

If you experience stability issues:

1. Gradually reduce the `arm_freq` and `gpu_freq` values.
2. Increase cooling if temperatures exceed 80°C.
3. If overclocking fails, try setting `force_turbo=1` in config.txt.
4. For Pi 4B, you can try setting `arm_freq_min` to a higher value (e.g., 1000) to maintain a minimum clock speed.
