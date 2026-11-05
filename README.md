# Road Traffic model

People commute between home and work along a network of roads. Roads wear out with use, which slows people down and pushes traffic onto other routes, and a council repairs the most worn roads each day.

The model is an example for [Cormas](https://github.com/cormas/cormas), made to show how to use links between entities and how to build a model. The story comes from the [Road Traffic tutorial of GAMA](https://gama-platform.org/wiki/RoadTrafficModel), adapted to a discrete grid. It uses the same mechanisms, with its own numbers, and does not try to reproduce the results of GAMA.

## Load and run

The model needs the `dev` branch of Cormas, which has links.

```st
Metacello new
    repository: 'github://cormas/road-traffic-model:main';
    baseline: 'RoadTrafficModel';
    load.
```

Open a simulation window:

```st
RTRoadTrafficModel scriptOpenSimulation
```

Choose `initTown` and `stepAlongTheLine`, initialize the simulation and run it.

## The model

| Entity | Class | What it is |
|---|---|---|
| Plot | `RTPlot` | A cell of the 50x50 grid, which is land, residential or industrial |
| Road | `RTRoad` | A link between two plots: one straight segment, usually many cells long |
| Street | `RTStreet` | A network of roads with a name, running from one end to the other or round in a loop |
| Town | `RTTown` | A network of all the streets |
| Person | `RTPerson` | An agent who lives in one place and works in another |
| Home and work links | `RTHomeLink`, `RTWorkLink` | Links from a person to their places |

**The town** is a table of streets in `RTRoadTrafficModel>>streetTable`, drawn by hand. A street is a name and the plots it passes through, with a straight road between each plot and the next. Change a plot to move a road. A street never branches, so a road meeting it at a junction belongs to another street.

**A day** has 100 steps. Each person leaves home at their own step between 10 and 25, and leaves work at their own step between 60 and 80. Where a person is going depends only on the time of day, so someone who is late turns round at the next junction.

**Walking.** At each junction, a person takes the first road of the cheapest route to their destination, found by `RTPlot>>cheapestRoadTo:`, which asks Cormas for the cheapest way through the town. People walk 2 to 3 cells per step on an unworn road, moving from cell to cell along it.

**Wear.** A road starts with a wear of 1, and each person entering it adds `wearPerUse`. Wear does two things:

- The cost of a road is `length * wear`, so people avoid worn roads when another route is cheaper.
- A person's speed on a road is `speed / wear`, so worn roads really are slower.

**Repairs.** At the start of each day, the council sets the wear of the `repairsPerDay` most worn roads back to 1.

## What it teaches

- **Links as real objects.** `RTRoad` is a subclass of `CMLink` with its own attributes and points of view. It connects plots that are far apart, which is what cells alone cannot do.
- **Querying links.** A person finds their home with `nextEntitiesLinkedBy:`. Naming the class keeps the question on home links, even though other links join the same plots.
- **Networks of links.** `RTStreet` and `RTTown` are subclasses of `CMNetwork`, each with its own points of view. A street is built with `addChainOf:through:`, and the town holds the streets.
- **Finding a way in a network.** `wayTo:in:cost:` compares the costs of the roads at this moment, and only uses roads of the town, so home and work links are never part of a route.
- **Direction as an attribute.** `RTRoad>>isDirected` answers whether the road is one-way, and ways respect it with no special code. Compare `initTown` with `initTownWithOneWays`, which is the same town with 4 streets running one way along their whole length.
- **Steps made of substeps.** A Cormas step is a substep of a day here. `stepOfDay` derives the time of day from the current time step, and each control method sends `dayStep` when a new day starts. The same pattern works for months and years. The alternative, one Cormas step per day with a loop inside, would update the view once a day, and people would appear to teleport.
- **Two ways of doing one thing.** The two control methods differ only in how people walk:
  - `stepAlongTheLine` goes through the cells that the drawn line crosses, using `RTRoad>>cellsTowards:`.
  - `stepWithMoveTowards` lets Cormas find the cells with `moveTowards:`. It needs no walking code of its own, but it goes diagonally first and then straight, so people leave sloped roads, and it runs more slowly.

## What you see

| Color | Meaning |
|---|---|
| Green to red road | Wear, fully red from a wear of 2.5 |
| Thicker road | More traffic so far, compared with the busiest road |
| Light amber person | Going home, or at home |
| Light blue person | Going to work, or at work |
| Deep amber plot | Residential |
| Deep blue plot | Industrial |

Roads have three points of view: `povWearAndTraffic`, the default, `povWear` and `povTraffic`. To see who lives and works where, select `pov` for `RTHomeLink` and `RTWorkLink`, which are hidden when the town is created.

Streets and the town can decide how their roads look, and the outermost network with an active point of view wins:

| To see | `RTTown` | `RTStreet` | `RTRoad` |
|---|---|---|---|
| How worn and busy the whole town is, as one color and width | `povWearAndTraffic` | Anything | Anything |
| How worn and busy each street is | `pov` | `povWearAndTraffic` | Anything |
| Which roads make up each street, each in a color of its own | `pov` | `povStreet` | Anything |
| Each road | `pov` | `pov` | Any of its points of view |

The charts follow `Mean wear`, `Max wear`, `People at home`, `People at work` and `People on the road`.

## Things to try

- Set `repairsPerDay` to 2 and then to 8, and run for 20 days. How worn does the town get, and how many people get to work on time?
- Set `repairsPerDay` to 0. What happens to the daily rhythm in the charts?
- Compare `stepAlongTheLine` with `stepWithMoveTowards`, and look at the sloped roads.
- Compare `initTown` with `initTownWithOneWays`.
- Change `numberOfPeople` or `wearPerUse`.
- Add a street to the table, or block one by removing its row. The tests check that everyone can still get to work and back.
- Harder: replace the daily repairs with a repair crew, an agent that walks to the most worn road and repairs it when it arrives.

## Parameters

| Parameter | Where | Default | Meaning |
|---|---|---|---|
| `numberOfPeople` | `RTRoadTrafficModel` | 30 | People in the town |
| `repairsPerDay` | `RTRoadTrafficModel` | 5 | Roads repaired at the start of each day |
| `wearPerUse` | `RTRoad` | 0.02 | Wear added each time a person enters a road |
