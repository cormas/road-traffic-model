"
I am a person who lives in one place in the town, works in another, and walks between them along the roads.

## Responsibility:

- Know my home and my workplace, through the links that connect me to them.
- Know where to go, which only depends on the time of day.
- Walk along one road at a time, and choose the next road at each junction.

## Collaborators:

- `RTHomeLink` and `RTWorkLink`: connect me to the plots where I live and work.
- `RTPlot`: where I stand, and what tells me the road to take.
- `RTRoad`: what I walk on. I wear it out by entering it, and its wear slows me down.
- `RTRoadTrafficModel`: tells me the step of the day.

## Public API and Key Messages

- `home` answers the plot where I live.
- `workplace` answers the plot where I work.
- `destination` answers where I should be going now.
- `walk` takes my walk for one step.

```
person := model newEntity: RTPerson locatedAt: homePlot.
model newEntity: RTHomeLink from: person to: homePlot.
model newEntity: RTWorkLink from: person to: workPlot.
person walk
```

## Internal Representation

- `leaveHomeStep` and `leaveWorkStep`: the steps of the day when I leave. I draw them once, when I am created.
- `speed`: the cells I walk per step on an unworn road.
- `progress`: how much of the next cell I have already walked. Speeds are fractional, so I take a step each time it reaches 1.
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
		'progress',
		'road',
		'roadEnd'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTPerson >> destination [
	"Where I should be going now. It only depends on the time of day, so a person who is late simply turns round at the next junction."

	^ (self cormasModel stepOfDay
		   between: leaveHomeStep
		   and: leaveWorkStep)
		  ifTrue: [ self workplace ]
		  ifFalse: [ self home ]
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
	speed := self randomBetween: 1 and: 2.
	progress := 0
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

{ #category : 'accessing' }
RTPerson >> speed: aNumber [

	speed := aNumber
]

{ #category : 'control' }
RTPerson >> walk [
	"Wear slows me down: progress grows by less on a worn road, and each whole unit of progress is one cell."

	self isOnRoad ifFalse: [ self enterRoadTowardsDestination ].
	self isOnRoad ifFalse: [ ^ self ].
	progress := progress + (speed / road wear).
	[ self isOnRoad and: [ progress >= 1 ] ] whileTrue: [
			self walkOneCell.
			progress := progress - 1 ].
	self isOnRoad ifFalse: [ progress := 0 ]
]

{ #category : 'control' }
RTPerson >> walkOneCell [

	self moveTowards: roadEnd.
	self cell = roadEnd ifTrue: [
			road := nil.
			self enterRoadTowardsDestination ]
]

{ #category : 'accessing' }
RTPerson >> workplace [

	^ (self nextEntitiesLinkedBy: RTWorkLink) first
]
