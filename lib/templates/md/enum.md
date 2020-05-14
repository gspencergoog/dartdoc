{{>head}}

{{#self}}
# {{{name}}} {{kind}}

{{>source_link}}
{{>categorization}}
{{/self}}

{{#eNum}}
{{>documentation}}

{{#hasModifiers}}
{{#hasPublicSuperChainReversed}}
**Inheritance**

- {{{linkedObjectType}}}
{{#publicSuperChainReversed}}
- {{{linkedName}}}
{{/publicSuperChainReversed}}
- {{{name}}}
{{/hasPublicSuperChainReversed}}

{{#hasPublicInterfaces}}
**Implemented types**

{{#publicInterfaces}}
- {{{linkedName}}}
{{/publicInterfaces}}
{{/hasPublicInterfaces}}

{{#hasPublicMixins}}
**Mixed in types**

{{#publicMixins}}
- {{{linkedName}}}
{{/publicMixins}}
{{/hasPublicMixins}}

{{#hasPublicImplementors}}
**Implementers**

{{#publicImplementors}}
- {{{linkedName}}}
{{/publicImplementors}}
{{/hasPublicImplementors}}

{{#hasAnnotations}}
**Annotations**

{{#annotations}}
- {{{.}}}
{{/annotations}}
{{/hasAnnotations}}
{{/hasModifiers}}

{{#hasPublicConstantFields}}
## Constants

{{#publicConstantFieldsSorted}}
{{>constant}}

{{/publicConstantFieldsSorted}}
{{/hasPublicConstantFields}}

{{#hasPublicConstructors}}
## Constructors

{{#publicConstructorsSorted}}
{{{linkedName}}}({{{ linkedParams }}})

{{{ oneLineDoc }}} {{{ extendedDocLink }}}  {{!two spaces intentional}}
{{#isConst}}_const_{{/isConst}} {{#isFactory}}_factory_{{/isFactory}}

{{/publicConstructorsSorted}}
{{/hasPublicConstructors}}

{{#hasPublicInstanceFields}}
## Properties

{{#publicInstanceFieldsSorted}}
{{>property}}

{{/publicInstanceFieldsSorted}}
{{/hasPublicInstanceFields}}

{{#hasPublicInstanceMethods}}
## Methods

{{#publicInstanceMethodsSorted}}
{{>callable}}

{{/publicInstanceMethodsSorted}}
{{/hasPublicInstanceMethods}}

{{#hasPublicInstanceOperators}}
## Operators

{{#publicInstanceOperatorsSorted}}
{{>callable}}

{{/publicInstanceOperatorsSorted}}
{{/hasPublicInstanceOperators}}

{{#hasPublicVariableStaticFields}}
## Static Properties

{{#publicVariableStaticFieldsSorted}}
{{>property}}

{{/publicVariableStaticFieldsSorted}}
{{/hasPublicVariableStaticFields}}

{{#hasPublicStaticMethods}}
## Static Methods

{{#publicStaticMethodsSorted}}
{{>callable}}

{{/publicStaticMethodsSorted}}
{{/hasPublicStaticMethods}}
{{/eNum}}

{{>footer}}