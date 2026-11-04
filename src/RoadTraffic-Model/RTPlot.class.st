"
I am a plot of land in the town of the road traffic model.

## Responsibility:

- Be a place that roads can join and that people can stand on.

## Collaborators:

- `RTRoadTrafficModel`: creates me as part of its grid.

## Public API and Key Messages

I answer everything a `CMCell` answers. Get all plots from the model:

```
model @@ RTPlot
```

"
Class {
	#name : 'RTPlot',
	#superclass : 'CMCell',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}
