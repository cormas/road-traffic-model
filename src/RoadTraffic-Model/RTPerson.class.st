"
I am a person who lives in one place in the town, works in another, and walks between them along the roads.

## Responsibility:

- Know my home and my workplace, through the links that connect me to them.
- Know where to go, which only depends on the time of day.
- Walk exactly on the drawn line of one road at a time, and choose the next road at each junction.
- Show where I am going: light amber towards home and light blue towards work.

## Collaborators:

- `RTHomeLink` and `RTWorkLink`: connect me to the plots where I live and work.
- `RTPlot`: where I stand, and what tells me the road to take.
- `RTRoad`: what I walk on. I wear it out by entering it, and its wear slows me down.
- `RTRoadTrafficModel`: tells me the step of the day.

## Public API and Key Messages

- `home` answers the plot where I live.
- `workplace` answers the plot where I work.
- `destination` answers where I should be going now.
- `walk` takes my walk for one step, with `moveStraight:towards:` from Cormas.
- `isAtHome`, `isAtWork` and `isOnRoad` tell what I am doing.

```
person := model newEntity: RTPerson locatedAt: homePlot.
model newEntity: RTHomeLink from: person to: homePlot.
model newEntity: RTWorkLink from: person to: workPlot.
person walk
```

## Internal Representation

- `leaveHomeStep` and `leaveWorkStep`: the steps of the day when I leave. I draw them once, when I am created.
- `speed`: how far I walk per step on an unworn road, in cell widths. It can be a fraction, and wear divides it.
- `road`: the road I am on, or nil when I am at a junction.
- `roadEnd`: the plot at the far end of that road.

"
Class {
	#name : 'RTPerson',
	#superclass : 'CMAgent',
	#instVars : [
		'leaveHomeStep',
		'leaveWorkStep',
		'speed',
		'road',
		'roadEnd'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'examples' }
RTPerson class >> examplePerson [

	<sampleInstance>
	^ (RTRoadTrafficModel exampleTown @@ self) first
]

{ #category : 'pov' }
RTPerson class >> homeColor [
	"A light shade of the color of residential plots, far from the red of worn roads. The link to my home uses it too."

	^ Color fromHexString: 'FFB000'
]

{ #category : 'pov' }
RTPerson class >> workColor [
	"A light shade of the color of industrial plots. The link to my workplace uses it too."

	^ Color fromHexString: '3AA0F2'
]

{ #category : 'accessing' }
RTPerson >> destination [
	"Where I should be going now. It only depends on the time of day, so a person who is late simply turns round at the next junction."

	^ (self cormasModel stepOfDay
		   between: leaveHomeStep
		   and: leaveWorkStep)
		  ifTrue: [ self workplace ]
		  ifFalse: [ self home ]
]

{ #category : 'pov' }
RTPerson >> destinationColor [

	^ self destination = self workplace
		  ifTrue: [ self class workColor ]
		  ifFalse: [ self class homeColor ]
]

{ #category : 'control' }
RTPerson >> enterRoadTowardsDestination [

	self cell = self destination ifTrue: [ ^ self ].
	road := self cell cheapestRoadTo: self destination.
	roadEnd := road otherEndOf: self cell.
	road recordUse
]

{ #category : 'accessing' }
RTPerson >> home [

	^ (self nextEntitiesLinkedBy: RTHomeLink) first
]

{ #category : 'initialization' }
RTPerson >> initialize [

	super initialize.
	leaveHomeStep := self randomIntegerBetween: 10 and: 25.
	leaveWorkStep := self randomIntegerBetween: 60 and: 80.
	speed := self randomBetween: 2.5 and: 3.5
]

{ #category : 'testing' }
RTPerson >> isAtHome [

	^ self isOnRoad not and: [ self cell = self home ]
]

{ #category : 'testing' }
RTPerson >> isAtWork [

	^ self isOnRoad not and: [ self cell = self workplace ]
]

{ #category : 'testing' }
RTPerson >> isOnRoad [

	^ road isNotNil
]

{ #category : 'accessing' }
RTPerson >> leaveHomeStep: aNumber [

	leaveHomeStep := aNumber
]

{ #category : 'accessing' }
RTPerson >> leaveWorkStep: aNumber [

	leaveWorkStep := aNumber
]

{ #category : 'pov' }
RTPerson >> pov [

	<pov>
	^ CMPointOfView color: self destinationColor size: 0.8
]

{ #category : 'accessing' }
RTPerson >> speed: aNumber [

	speed := aNumber
]

{ #category : 'control' }
RTPerson >> walk [
	"I walk exactly on the drawn line of my road, towards its far end, and choose my next road when I reach the center of that end. Wear slows me down: on a road twice as worn, I cover half the distance."

	self isOnRoad ifFalse: [ self enterRoadTowardsDestination ].
	self isOnRoad ifFalse: [ ^ self ].
	self moveStraight: speed / road wear towards: roadEnd.
	(self isAtCenterOf: roadEnd) ifTrue: [
			road := nil.
			self enterRoadTowardsDestination ]
]

{ #category : 'accessing' }
RTPerson >> workplace [

	^ (self nextEntitiesLinkedBy: RTWorkLink) first
]
