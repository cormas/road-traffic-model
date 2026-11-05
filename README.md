# Road Traffic model

People commute between home and work along a network of roads. Roads wear out with use, which slows people down and pushes traffic onto other routes, and a council repairs the most worn roads each day.

The model is an example for [Cormas](https://github.com/cormas/cormas), showing how to use links and networks of links. The story comes from the [Road Traffic tutorial of GAMA](https://gama-platform.org/wiki/RoadTrafficModel), adapted to a grid of cells.

**Documentation:** https://cormas.org/models/road-traffic

## Install

The model needs a version of Cormas with links and networks, which for now is the `dev` branch. In a Cormas image, execute:

```st
Metacello new
    repository: 'github://cormas/road-traffic-model:main/src';
    baseline: 'RoadTrafficModel';
    load.
```

Then open a simulation window:

```st
RTRoadTrafficModel scriptOpenSimulation
```
