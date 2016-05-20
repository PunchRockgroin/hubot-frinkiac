# hubot-frinkiac-me
Frinkiac plugin for hubot. Searches and generates images and memees from [Frinkiac](https://frinkiac.com/), an awesome Simpsons scene index.

## Installation
From your hubot instance:
```
npm install hubot-frinkiac-me --save
```

Don't forget to add `hubot-frinkiac-me` to the `external-scripts.json` file

## Configuration Environment Variables
* `HUBOT_FRINKIAC_MEMEIFY` - True to place meme with caption on the image (Default: true)
* `HUBOT_FRINKIAC_RANDOMIZE` - True to randomize the selected image (Default: false)
* `HUBOT_FRINKIAC_RESPOND_ONLY` - True to respond only when directly addressed, false to respond to all messages (Default: false)

## Example Usage
```
hubot> frinkiac me donuts and the possibility of more donuts
```

![Meme](https://frinkiac.com/meme/S08E02/808223.jpg?lines=+like+doughnuts+and+the%0A+possibility+of+more%0A+doughnuts+to+come.+I+knew%0A+you%27d+do+well%2C+Homer.#.png)

## Changelog

#### 1.0.0
* Fixed URLs to point to "frinkiac.com", resolving [#1](https://github.com/morinap/hubot-frinkiac/issues/1)
* Update code style to match JS standards
* Updated package documentation

#### 0.2.0
* Add support for "meme-ifying" - adding caption to image
* Add environment variables `HUBOT_FRINKIAC_MEMEIFY`, `HUBOT_FRINKIAC_RANDOMIZE`, and `HUBOT_FRINKIAC_RESPOND_ONLY` to control behavior

#### 0.1.0
* Initial Version
