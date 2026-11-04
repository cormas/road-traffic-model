Class {
	#name : 'BaselineOfRoadTrafficModel',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfRoadTrafficModel',
	#package : 'BaselineOfRoadTrafficModel'
}

{ #category : 'baselines' }
BaselineOfRoadTrafficModel >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: 'RoadTraffic-Model';
				package: 'RoadTraffic-Tests'
				with: [ spec requires: #( 'RoadTraffic-Model' ) ] ]
]
