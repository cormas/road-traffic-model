"
I am a town where people commute along a network of roads. My story comes from the Road Traffic tutorial of GAMA, adapted to the discrete grid of Cormas.

## Responsibility:

- Create the town: a grid of plots and a network of roads drawn by hand in a table.
- Know which plots are residential and which are industrial.
- Create the people, each with a home and a workplace chosen at random.
- Keep time: a Cormas step is a substep of a day, and `stepOfDay` tells which one.

## Collaborators:

- `RTPlot`: the cells of my grid.
- `RTRoad`: the links between plots that make up the network.
- `RTPerson`: the people of the town.
- `RTHomeLink` and `RTWorkLink`: connect people to their places. I hide these lines when I create the town, and selecting their point of view shows them.

## Public API and Key Messages

- `initTown` creates the town with two-way roads.
- `initTownWithOneWays` creates the same town and applies the one-way marks of the table.
- `stepWithMoveTowards` and `stepAlongTheLine` run one step, and differ only in how people walk along a road.
- `residentialPlots` and `industrialPlots` answer the places where people live and work.
- `stepOfDay` answers the step of the current day.
- `numberOfPeople` is a parameter.

Run me through a simulation, as any other Cormas model:

```
model := RTRoadTrafficModel new.
simulation := CMSimulation for: model.
simulation
	activeInitSelector: #initTown;
	activeControlSelector: #stepAlongTheLine;
	initializeSimulation.
simulation runStep.
model @@ RTPerson
```

## Internal Representation

- `numberOfPeople`: an integer.

"
Class {
	#name : 'RTRoadTrafficModel',
	#superclass : 'CMModel',
	#instVars : [
		'numberOfPeople'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTRoadTrafficModel class >> modelName [

	^ 'Road Traffic'
]

{ #category : 'init' }
RTRoadTrafficModel >> createPeople [
	"Everyone starts at home. The lines from people to their places are hidden, because so many of them would hide the roads."

	| homes workplaces |
	homes := self residentialPlots.
	workplaces := self industrialPlots.
	self numberOfPeople timesRepeat: [
			| home person |
			home := self selectRandomlyFrom: homes.
			person := self newEntity: RTPerson locatedAt: home.
			self newEntity: RTHomeLink from: person to: home.
			self
				newEntity: RTWorkLink
				from: person
				to: (self selectRandomlyFrom: workplaces) ].
	RTHomeLink activePovSelector: #povInvisible.
	RTWorkLink activePovSelector: #povInvisible
]

{ #category : 'init' }
RTRoadTrafficModel >> createRoads [

	self roadTable do: [ :row |
			self
				newEntity: RTRoad
				from: (self cellAt: row first at: row second)
				to: (self cellAt: row third at: row fourth) ]
]

{ #category : 'init' }
RTRoadTrafficModel >> createTown [

	self
		createGridNumberOfRows: 50
		numberOfColumns: 50
		neighbourhood: 8
		closed: true.
	self createRoads.
	self markPlaces.
	self createPeople
]

{ #category : 'map' }
RTRoadTrafficModel >> industrialPlaces [
	"The plots where people work, as row and column."

	^ #( #( 38 45 ) #( 46 27 ) #( 17 47 ) )
]

{ #category : 'accessing' }
RTRoadTrafficModel >> industrialPlots [

	^ self @@ RTPlot select: [ :plot | plot isIndustrial ]
]

{ #category : 'init' }
RTRoadTrafficModel >> initTown [

	<init>
	self createTown
]

{ #category : 'init' }
RTRoadTrafficModel >> initTownWithOneWays [

	<init>
	self createTown.
	self makeMarkedRoadsOneWay
]

{ #category : 'init' }
RTRoadTrafficModel >> makeMarkedRoadsOneWay [
	"Roads are created in the order of the table."

	self @@ RTRoad
		with: self roadTable
		do: [ :road :row | row size = 5 ifTrue: [ road beOneWay ] ]
]

{ #category : 'init' }
RTRoadTrafficModel >> markPlaces [

	self residentialPlaces do: [ :place |
		(self cellAt: place first at: place second) beResidential ].
	self industrialPlaces do: [ :place |
		(self cellAt: place first at: place second) beIndustrial ]
]

{ #category : 'parameters' }
RTRoadTrafficModel >> numberOfPeople [

	<parameterIntegerMin: 1 max: 500 default: 30>
	^ numberOfPeople
]

{ #category : 'parameters' }
RTRoadTrafficModel >> numberOfPeople: aNumber [

	numberOfPeople := aNumber
]

{ #category : 'map' }
RTRoadTrafficModel >> residentialPlaces [
	"The plots where people live, as row and column."

	^ #( #( 6 8 ) #( 4 22 ) #( 18 3 ) #( 35 4 ) #( 43 10 ) #( 5 38 )
	     #( 46 22 ) #( 25 25 ) )
]

{ #category : 'accessing' }
RTRoadTrafficModel >> residentialPlots [

	^ self @@ RTPlot select: [ :plot | plot isResidential ]
]

{ #category : 'map' }
RTRoadTrafficModel >> roadTable [
	"The roads of the town, one straight segment per row: from row, from column, to row, to column. A street that bends is several rows that share a plot. A last #oneWay makes the road one-way from its first plot to its second, when the town uses one-way roads. Change a row to move a road."

	^ #( #( 18 22 19 30 ) #( 19 30 25 33 ) #( 25 33 31 29 )
	     #( 31 29 32 21 ) #( 32 21 26 17 ) #( 26 17 18 22 )
	     #( 25 25 18 22 ) #( 25 25 25 33 #oneWay )
	     #( 25 25 32 21 ) #( 18 22 11 19 ) #( 11 19 4 22 )
	     #( 19 30 12 33 ) #( 12 33 5 38 ) #( 5 38 3 46 ) #( 11 19 9 26 )
	     #( 9 26 12 33 #oneWay ) #( 9 26 4 22 ) #( 25 33 22 41 )
	     #( 22 41 17 47 ) #( 12 33 15 39 ) #( 15 39 22 41 #oneWay )
	     #( 15 39 17 47 ) #( 31 29 33 38 ) #( 33 38 38 45 )
	     #( 31 29 39 31 ) #( 39 31 46 27 ) #( 33 38 39 31 )
	     #( 41 25 39 31 #oneWay ) #( 41 25 39 18 ) #( 41 25 46 27 )
	     #( 32 21 39 18 ) #( 39 18 46 22 ) #( 39 18 43 10 )
	     #( 26 17 22 10 ) #( 22 10 18 3 ) #( 26 17 30 10 )
	     #( 30 10 35 4 ) #( 22 10 30 10 #oneWay )
	     #( 30 10 39 18 ) #( 35 4 43 10 ) #( 18 22 13 12 )
	     #( 13 12 6 8 ) #( 13 12 22 10 ) )
	"The ring around the centre, and the centre"
	"North"
	"East"
	"South"
	"West"
]

{ #category : 'control' }
RTRoadTrafficModel >> stepAlongTheLine [

	<control>
	self @@ RTPerson do: [ :person | person walkAlongTheLine ]
]

{ #category : 'time' }
RTRoadTrafficModel >> stepOfDay [
	"A Cormas step is a substep of my day. The current time step grows for ever, so the step of the day, from 1 to stepsPerDay, comes from it. Months or years would work the same way."

	^ self currentTimeStep - 1 \\ self stepsPerDay + 1
]

{ #category : 'control' }
RTRoadTrafficModel >> stepWithMoveTowards [

	<control>
	self @@ RTPerson do: [ :person | person walkWithMoveTowards ]
]

{ #category : 'time' }
RTRoadTrafficModel >> stepsPerDay [

	^ 100
]
