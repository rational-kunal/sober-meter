# Sober Meter 🍻❓

Are you sure you can drive? Know it with this simple but inaffective tool 😅.

***

I developed this app with a focus on mastering the [Core ML](https://developer.apple.com/documentation/coreml) and [Create ML](https://developer.apple.com/documentation/createml) APIs.

The app presents challenging math questions, requiring users to provide their answers to assess their sobriety.
To achieve this, I harnessed Apple's MNIST model, which recognizes handwritten digits.
Moreover, I integrated PencilKit to offer users a canvas for drawing their responses.

<img height="540px" src="https://github.com/rational-kunal/Netflix-Hotkeys/assets/28783605/c3a28f00-3e69-4672-b007-4b53e96c3fa7" />

During my learning process, debugging the ML model posed a significant challenge.
Initially, the model's accuracy was subpar.
To improve it, I addressed two pivotal issues: a) modifying the input format to white on black and b) increasing the marker width on the canvas.

***

_Used util classes from: [CoreMLHelpers](https://github.com/hollance/CoreMLHelpers)_
