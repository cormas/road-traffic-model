"
I am the whole town, made of all its streets. I am what people look for a way through.

## Responsibility:

- Hold the streets of the town, so that all its roads can be reached through me.

## Collaborators:

- `RTStreet`: my members.
- `RTRoadTrafficModel`: creates me and keeps me as its town.

## Public API and Key Messages

- `members` answers my streets.
- `links` answers all the roads of the town, as for any network.

```
model town members. ""the streets""
model town links. ""all the roads""
```
"
Class {
	#name : 'RTTown',
	#superclass : 'CMNetwork',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'examples' }
RTTown class >> exampleTown [

	<sampleInstance>
	^ RTRoadTrafficModel exampleTown town
]
