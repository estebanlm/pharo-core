"
Checks for senders of comparator messages that do not use the result of the comparison.
"
Class {
	#name : #RBEqualNotUsedRule,
	#superclass : #ReNodeBasedRule,
	#category : #'GeneralRules-Migrated'
}

{ #category : #accessing }
RBEqualNotUsedRule class >> uniqueIdentifierName [
	"This number should be unique and should change only when the rule completely change semantics"
	
	^'EqualNotUsedRule'
]

{ #category : #'as yet unclassified' }
RBEqualNotUsedRule >> check: node forCritiquesDo: aCriticBlock [
	(node isMessage
		and: [ node isUsed not
				and: [ #(#= #== #~= #~~ #< #> #<= #>=) includes: node selector ] ])
		ifTrue: [ aCriticBlock cull: (self critiqueFor: node) ]
]

{ #category : #accessing }
RBEqualNotUsedRule >> group [
	^ 'Potential Bugs'
]

{ #category : #accessing }
RBEqualNotUsedRule >> name [
	^ 'Doesn''t use the result of a =, ~=, etc.'
]
