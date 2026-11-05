"
I am a street of the town: a few roads that belong together and share a name. Most of me bend, so I am usually several of the straight roads of the town, and some of me branch, as a real street can.

## Responsibility:

- Hold the roads of this street.
- Know my name.

## Collaborators:

- `RTRoad`: my members.
- `RTTown`: contains me.
- `RTRoadTrafficModel`: creates me from its table of streets.

## Public API and Key Messages

- `name` answers my name.
- `links` answers my roads, as for any network.
- `povStreet` shows all my roads in a color of my own, to see which roads make up each street.
- `meanWear`, `meanUses` and `povWearAndTraffic` come from `RTRoadNetwork`.

```
street := model newEntity: RTStreet.
street name: 'Market Street'.
street add: road
```

## Internal Representation

- `name`: a string.
"
Class {
	#name : 'RTStreet',
	#superclass : 'RTRoadNetwork',
	#instVars : [
		'name'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'examples' }
RTStreet class >> exampleRingRoad [

	<sampleInstance>
	^ RTRoadTrafficModel exampleTown town members first
]

{ #category : 'accessing' }
RTStreet >> name [

	^ name
]

{ #category : 'accessing' }
RTStreet >> name: aString [

	name := aString
]

{ #category : 'pov' }
RTStreet >> povStreet [
	"All my roads show a color of my own. Turning the hue by the golden angle for each id keeps the colors of consecutive streets far apart, however many there are"

	<pov>
	^ CMPointOfView
		  color: (Color h: self id * 137.5 \\ 360 s: 0.8 v: 0.8)
		  size: 0.4
]
