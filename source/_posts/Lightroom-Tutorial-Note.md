---
title: Lightroom Tutorial Note
date: 2019-09-23 22:01:26
updated:
categories: Photography
tags:
- Lightroom
- Note
---

Notes of Lightroom Tutorial

## Landscape
### RGB Curves
Learn how to use the RGB Curves to shift and shape color to apply corrective adjustments and/or creative interpretations to your images.

#### RGB Curves
The RGB Curves are part of the Point Tone Curve, which allow you to adjust the tonal values of the Red, Green, and Blue values independently to shift and refine color with great control.

Yellow is the opposite of blue, magenta is the opposite of green, and cyan is the opposite of red. So when dragging UP on a given curve we add that curve's color, and dragging DOWN adds its opposite color.

This landscape photo has a lot of blue in the shadow tones. We can use the RGB curves to remove the bluish cast in the shadows without removing it from the lighter areas in the sky, while also subtly boosting contrast.

We'll start by placing a point on the Blue curve in the shadow region and drag downward slightly to add yellow and contrast to the shadows.

Adding yellow left the shadows a little green. Drag down on the shadow region of the Green curve to add magenta and fix that.

### Removing Haze and Adding Contrast
Aerial haze can reduce the overall image sharpness and contrast.

#### Crop to show off the main subject
`Crop`: Crop away some of the outside edges to really show off the mountain in this photo.

#### Removing Haze
The photo has a hazy and low contrast look.

`Dahaze + 60`: Use the Dehaze slider to reduce the haze.

#### Add some warmth
A common side effect of Haze Reduction is the photo tends to get blue. We can counteract that with the White Balance Temperature slider.

`Temp 6036K`: Drag the Temp slider to the right to warm the photo.

#### Reduce the Saturation
Another side effect of the Dehaze slider is that sometimes the blue in the sky get too saturated.

`Color Mix: Blue Saturation - 10`: Only desaturate the blues in the photo.

<!-- more -->

### Boosting Fall Colors
Fall is just about every landscape photographer's favorite time of year to shoot. But sometimes it seems that the colors aren't as rich and vibrant as you expected. With a little help, we can boost them and get those nice reds and oranges.

#### Brighten the Photo
`Exposure + 0.6`

#### Boost the Fall-like Colors
The primary fall colors that everyone loves include the bright reds, oranges and yellows. With a few adjustments we can boost the saturation of each one of these.

`Color Mix: Red Hue + 10`: Adjust the Hue of the Reds to bring more of the fall look to them.
`Color Mix: Red Saturation + 75`: Adjust the Saturation to make the reds more vivid.
`Color Mix: Orange Hue - 30`: Move the Orange Hue to make the colors more red.
`Color Mix: Orange Saturation + 40`: Adjust the Saturation to make the colors more vivid.
`Color Mix: Yellow Hue - 40`: Move the Yellow Hue slider to move those colors more toward orange.
`Color Mix: Yellow Saturation + 60`: Adjust the Saturation to make the yellows more vivid.
`Color Mix: Green Hue - 70`: Make the green tones more yellow.
`Color Mix: Green Saturation + 20`: Add some saturation to those colors as well.

#### Finishing Touches
Depending on how bright or dark the photo was to start with, you can always go back to your basic Light settings and make some final adjustments.

`Whites + 50`: The bright areas were still dark, so move the whites slider to brighten them.

### Dealing with Dull Skies with the Linear Gradient Tool
Bright skies and dark foregrounds are a very common scenario faced by photographers. Balancing out the tones will make the image look much more appealing and the Linear Gradient tool is up to the task.

#### Linear Gradient
The sky is way too light. Add a Gradient to darken the sky with Exposure and add a bit of 'life' to it with Clarity.

`Selective Edits: Linear Gradient`: Drag a Gradient so that it's parallel to the horizon and wide enough to blend in between the hills and the sky. The width of a Linear Gradient determines its softness. Too soft is a bad idea so, counter intuitively, narrower Gradients often work best.
`Linear Gradient: Exposure - 0.77`: Darken the sky a bit.
`Linear Gradient: Clarity + 63`: Adding Clarity to the sky makes the clouds more distinct, which adds some drama.

#### Light
Once we have improved the sky we will use global adjustments to improve the overall tonality.

`Contrast + 74`
`Highlights - 50`
`Shadows + 90`: Lighten the dark tones to open up the shadows and reveal the ship's textures all the better.

#### Effects
Clarity brings out the details of the ships hull - it works well on rusty and textured objects.

`Clarity + 25`: Accentuate details in the ship's hull and the beach rocks.
`Vignette - 20`: Darken the edges of the photo to hold the eye in the shot.

### Sharpening Landscape Photos
In landscape photography, sharpness and focus are especially important. In this tutorial, you'll learn how to add a great final touch of sharpening to accentuate important details.

#### Sharpening your photos with the Detail Panel
Before we get started, it's always a good practice to zoom in (pinch zoom) on your photo before sharpening.

`Sharpening 100`: Sharpening is basically adding contrast to edges and details. So think of that Sharpness slider as the amount of contrast you're going to add.

#### Adjusting Radius
Once Lightroom detects an edge to sharpen, the Radius slider controls how far around that edge to apply the sharpening. High values may create unsightly haloing effects, so it is best to be judicious with the Radius slider.

`Radius 0.8`: Move the Radius to a setting just under 1.0 for tiny details. While the Radius will be different for every photo, you'll usually want a pretty low number (less than 1) for very detailed and textured photos. For less detailed images such as a water or foggy scenes experiment with higher values.

#### Adjusting the Detail Slider
The Detail slider tells Lightroom how many details it should look for in the photo. Lower settings mean it'll look for only super contrasty stuff to sharpen. Higher settings mean it'll affect more areas.

`Detail 65`: Increase the Detail slider to affect more of the small details in the photo.

#### Hide (or Mask) the Sharpening From Smooth Areas
The masking slider hides the sharpening from the less detailed and smoother areas in the image, such as skies or flat surfaces that do not to be sharpened as much.

`Masking 10`: Move the Masking slider to the right and it won't affect the water as much.

Whenever you're done sharpening, it's always a good practice to tap and hold on your photo to see the before/after.

### Creating Dramatic Contrast in a Washed-Out Landscape Image
The midday sun in an environment like Maui's Haleakala Crater can wash out tones. Build contrast and shape color to transform a washed-out landscape image into a moody and dramatic final product.

#### Light
Since so much of this scene is a similar medium tone, adding a lot of contrast will spread out the dynamic range of the image. First maximize what you can do with the Whites and Blacks.

`Whites + 36`: First to get dramatic contrast, brighten the Whites as much as possible without losing highlights.
`Blacks - 5`: Darken the Blacks to get the richest Blacks possible without losing important shadow information.
`Contrast + 15`: Increase overall contrast and refine the contrast even more in the next step.
`Curve: S-curve`

#### Color
Increasing the saturation and controlling luminosity of specific colors in this scene can add interest and depth.

`Vibrance + 15`: Increase Vibrancy to make the subtle reds of the volcanic sands and greens of the mountain appear more vivid.
`Color Mix: Blues Saturation - 25`: By increasing vibrance of all colors, the blue sky is too blue, so bring it back a bit, closer to the other colors.
`Color Mix: Blues Luminance - 30`: Darkening the blue tones of the sky will help get more contrast with the clouds and give the image more drama.

#### Effects
The Effects can increase texture, which is the main subject of what could otherwise just be flat gravelly grey sand.

`Clarity + 24`: Using the Clarity slider will enhance the contrast in the midtones, in this case the areas of rocks and sand.

#### Detail
Sharpening is important in adding interest to landscape images to make all the details stand out.

`Sharpening 75`: Sharpening the photo will also encourage the viewer to notice the details of the rocks.
`Radius 1.2`: Increase the impact of the sharpening and make the rocks and edges of the landscape pop.

### Perfect Turquoise Water

#### Crop
Most Social Media is consumed on a vertical device such as a phone, so vertical images will work best as they fill the screen. For Instagram the optimal ratio is 4:5 and you can choose the 4x5 ratio from the Crop presets.

`Crop`: Place important subjects one third from the top or bottom. This is a classic composition rule that still works very well.

#### Light
Especially on cloudy days, images often look flat and low in contrast. That's easy to correct. Plus we'll use the Tone Curve to adjust the image contrast to create a popular Instagram look.

`Contrast + 56`: Get rid of the dullness and make the picture look more brilliant.
`Highlights - 32`: Darken the bright tones.
`Shadows + 35`: Lighten the dark tones to see more information in the mountain and water areas.
`Whites + 27`: Brighten the bright tones. This will also add some brilliance to the image and make it look like the sun is shining.
`Curve`: If you want the rest of the Curve not to be influenced by the adjustments you made, set anchor points above and below your change on the diagonal line to lock those values from being changed.

#### Color
The water is still way too green, what doesn't look natural at all. We want it to look like an ice cold turquoise glacial lake.

`Color Mix: Aqua Hue + 43`: Make the aqua tones more blue.
`Color Mix: Aqua Saturation + 62`: Make the aqua tones richer.
`Color Mix: Blue Luminance - 35`: Darken the blue tones.

### 2.5 minutes of total solar eclipse
Learn how to process the strange and beautiful light from a solar eclipse. Give depth and richness to the shadow of the moon as it passes across the sun, and accentuate the symmetry and negative space of your composition.

#### Crop
I composed the image so that the eclipse was central but to have most of the photo consists of sky. The composition is just slightly off so I begin by making an adjustment to crop and angle.

`Crop`: Center the eclipse but position it slightly lower in the picture.

The reason I used a wide angle lens is because I wanted to capture the effect of the moon shadow across the sky and landscape. The focal point is not the eclipse itself, but rather the subtle gradations in light and color.

#### Light
The raw image really didn't reflect my memory of the eclipse. The picture needed substantial changes in exposure to recreate the night tones which pervaded the sky.

`Exposure - 1.58`: Darken the image so that the deepest parts of the sky are almost black. It is essentially night time inside the shadow!
`Curve: S-curve`

#### Color
Now that the light is in a good place. Work with the color to adjust the mood and atmosphere of the picture.
To see the subtle color shifts, pinch zoom to the center of the image and work alone.

`Temp 3846K`: Decrease Temperature to make the photo cooler. The sky was a very dark indigo, the color of night.
`Vibrance + 18`: Make the colors more vivid by increasing Vibrance. I tend to use this function over Saturation.
`Saturation + 10`: Increase Saturation slightly but not by too much. I prefer to saturate colors individually or use Vibrance.
`Color Mix: Orange Hue - 7`: Shift the orange hues slightly towards red to deepen the tone.
`Color Mix: Yellow Hue - 6`: Shift the yellow more orange. The yellow/orange tones on the horizon will be main saturated colors in the photo.

#### Effects
Add some structure to the mountain with the Clarity slider.

`Clarity + 37`: Enhance the micro contrast in the midtones and makes the image look defined.

### Improving a Sunrise Portrait
Improve a portrait captured at sunrise that's too dark.

#### Light
When the image was captured, the exposure was set to ensure good detail in the sky and clouds. But this left the figure in the foreground dark and underexposed.

`Shadows + 100`: Begin by lightening the dark and underexposed tones.
`Contrast + 100`: The increase in shadows makes the image feel bland so let's increase image contrast.
`Exposure + 0.11`: Slightly brighten the overall photo.
`Highlights - 100`: The very light tones are too bright, so recover those tone by decreasing the Highlights.
`Whites + 16`: Slightly brighten the bright tones.
`Blacks - 50`: Drag the Blacks slider to the left to add more density and contrast.

#### Color
Add Some style by slightly boosting the colors.

`Vibrance + 13`: Make the colors more vivid.
`Saturation + 6`: Slightly increase color intensity.

#### Effects
Clarity, Dehaze and the Slit Toning controls can help us to create more visual interest.

`Clarity + 30`: Accentuate details and add visual snap.
`Dehaze + 10`: Reduce atmospheric haze and darken light tones.
`Split Toning: Shadows H: 231° S: 22`: Select a blue color for the darker tones.
`Split Toning: Highlights H: 48° S: 20`: Select a yellow for the light tones.

#### Detail
Brighten shadows can reveal unwanted noise. So let's fix that and add some overall sharpening.

`Noise Reduction 60`: Smooth out the noise in the photo.
`Color Noise Reduction 60`: Remove colored noise artifacts.
`Sharpening 72`: Accentuate details throughout the photo.

#### Optics
Shooting directly into the sun with a wide angle lens may result in unwanted color fringing and distortion.

`Remove Chromatic Aberration`: Remove unwanted color from around objects and bright highlights.
`Enable Lens Corrections`: Apply automatic Lens Corrections.

### Bringing a Sunrise to Life
Getting the right tonality and color in a sunrise can be really tricky.

#### Improving the Composition With Crop
Getting the composition right in the camera is a great goal to strive for. For those times that the frame isn't exactly what you had imagined, the Crop tool can really transform your photo.

`Crop`: Use the crop to split the image into two halves of sky (top) and sea (bottom).

#### Getting the Colors Right with White Balance
Shooting during sunrise and shooting on the coast can both throw the auto white balance settings off, resulting in a scene that doesn't match your memory. Temperature and Tint are invaluable tools to control color in a photo.

`Temp 10280K`: increase the warmth of the image by increasing the Temperature slider.
`Tint + 38`: Increasing Tint adds magenta, removing the slight green cast from the photo.
`Saturation + 30`: To make the colors of the sunrise stand out, increase Saturation a bit.

#### Balancing Contrast
Now that the colors look much better, it's time to balance tonality and contrast. We're going to want to retain the sleepy sunrise mood while adding a bit of punch through contrast.

`Contrast + 60`
`Highlights - 100`: The sky is too bright, reduce Highlights to bring details back to the clouds.
`Shadows + 35`: Shadows can act like a flashlight for dark area, bringing details back.
`Whites + 45`: Recovering highlights made the photo a bit dingy, use Whites to clean it up.
`Blacks - 20`: Add some blacks to the image to ensure there's a rage from black to white.
`Curve: S-curve`

#### Adding Depth With a Vignette
The Vignette control can add depth to a photo by drawing the viewer's gaze towards the center of the photo. We'll first remove the vignette unique to this lens and then apply a vignette to the cropped area.

`Enable Lens Corrections`
`Vignette - 30`: Darken the edges, taking care not to create too obvious of an effect.
`Midpoint 8`: Move the Midpoint to the left to bring the effect into the photo even more.
`Roundness - 12`: Make the vignette a tiny bit less round.
`Feather 90`: Increasing Feather ensures that the edge of the effect isn't visible.

### Bring Focus and Interest to Your Travel Photographs

#### Effects
My workflow for processing architectural images stars with Clarity as a high Clarity setting can change the overall image exposure.

`Clarity + 30`: Adds details and visual snap to the mid-tones.

#### Light
The image needs to be brightened and Shadow detail added to make the Exposure correct. Increasing the Contrast will give the image a little more pop.

`Exposure + 0.1`: Bring up the Exposure slider to brighten the overall photo.
`Shadows + 70`: Open up the shadows to reveal important shadow details.
`Contrast + 36`

#### Color
The image needs some color intensity and the sky should be darker. This will achieved by using the Vibrance slider and darken the blue sky tones.

`Vibrance + 38`: Make the colors more vivid without over-saturating them.
`Color Mix: Blue Luminance - 10`: Darken the blue tones, which is something I do on almost all of my exterior photographs.
`Color Mix: Blue Hue + 13`: Make the blue tones more purple to give the images a more natural looking sky.
`Color Mix: Blue Saturation - 10`: Make the blue tones less colorful to make the sky look more natural.

#### Linear Gradient
The bottom of the image needs to be darker and we'll do that with the Linear Gradient Filter.

`Selective Edits: Linear Gradient`: Start in the grass and pull up to about halfway up the image.
`Linear Gradient: Exposure - 0.6`

#### Geometry
The building is not perfectly straight and it can be corrected using the Guided Upright tool.

`Upright: Guided`: Select Guided and draw a line down the left side of the lighthouse. Then draw a line down the right side of the lighthouse to straighten the building.

#### Crop
Remove all the distractions so the center of attention is on the most important element in the image - the lighthouse.

`Crop`: Use the Crop tool to remove unwanted areas and recompose the image.

#### Effects
Adding a Vignette to your image helps focus your viewer's attention on the center of the iamge.

`Vignette - 14`: Darken the edges of the photo. You do not want to go so far that you will notice the effect.
`Midpoint 48`: Make the darkening effect larger and bring it into the image.
`Feather 57`: As we increased the Midpoint we use Feathering to soften the transition of the darkening effect.

## Portraits
### Creating a High Key Image
Highkey is light and bright. This photo needs to be all about the lightest tones so let's use the Light tools to create an image with no deep shadows, one that emphasizes the soft fur, and the perky expression of this dog.

#### Light
High key images are light and airy, with no blacks and low contrast. Let's brighten this image and make sure the lightest tones are under control.

`Exposure + 1`: Brighten the overall photo by the equivalent of one stop.
`Highlights - 75`: Combined with the next stop, reducing the highlights adds contrast to the highlights only.
`Whites + 10`: Brighten the brightest tones to make the whites as bright as can be without clipping.
`Shadows + 70`: Lighten the dark tones to make sure there are no harsh shadows.

#### Color
Warm toned images always look more appealing and this friendly dog is slightly straw colored anyway

`Temp 7725K`: Push the Temp up to add warmth to the photo and bring out the orange colors of the fur.
`Saturation + 27`: Increase color intensity to further bring out the fur color.

#### Effects
Negative Texture can soften an image in a pleasing way.

`Texture - 36`: Soften details throughout the photo.
`Vignette - 27`: Darken the edges of the photo to hold the eye in the frame.

#### Detail
Too much sharpening will spoil the nice soft effect we have created so we will back it off a bit.

`Sharpening 25`: Reduce the sharpening of the details in the photo.
`Noise Reduction 10`: Smooth out the noise in the photo.

### Make a dark dog shine
Dogs with dark fur are hard to photograph. Often, their features get lost, making for dull portraits.

#### Light
Bring light into the dark fur, preserve the white fur, and make your dog shine.

`Exposure + 0.1`: Make sure your portrait's overall Exposure is balanced, but don't use the Exposure tool to bring out details yet.
Although Exposure is a great way to adjust light in many situations, it's not the right tool for a portrait like this. We need more specific adjustments, to retain the details of the portrait abd the dog's features.
`Contrast + 32`: Start by boosting the Contrast, as a great way to bring drama and sass to any portrait.
`Highlights + 3`: Because this dog has a lot of white fur, I won't push the Highlights, but notice what it does to black fur, and use as needed.
`Shadows + 56`: This is the key adjustment for dark fur. See how much light you can bring into the fur, revealing all these amazing details.
`Whites - 67`: Bringing the Whites down reveals more texture in the white fur. It's nice if you don't want the white fur to be blown out.
`Blacks - 30`: Darken the Blacks to retain some of the drama of the black fur.

#### Effects
Effects are a great way to give personality to your photos, and develop your own unique style.

`Clarity + 47`: Gently accentuate details and add punch to a portrait.

#### Color
The possibilities with Color adjustment are endless. This is a great place to continue exploring your own style.

`Vibrance + 57`
`Saturation - 10`: Bring Saturation down a bit, so that the expression of the dog isn't outshined by the presence of intense colors.

Next, let's work on adjusting colors more selectively. For example: if your dog's tongue is out, it's a good idea to pay attention to it. Its color and vibrancy can make your dog look happier and healthier.

`Color Mix: Red Saturation + 22`: Make the red tones more vivid, just to bring more life into the tongue of the dog.
`Color Mix: Red Luminance - 10`: Darken the red tones, to fix the pink of the tongue.
`Color Mix: Magenta Hue + 42`: Adjust the Hue of the tongue only, by making the modifying the Magenta Hue.

Next, the eyes! Possibly the most important part of the portrait. Play with their color and make them pop.

`Color Mix: Orange Saturation + 32`
`Color Mix: Orange Luminance - 18`

The following step is great if your dog has white fur. That fur can appear a bit yellowish. Let's tone that down.

`Color Mix: Yellow Saturation - 76`: By decreasing the Yellow saturation, I removed the yellow hue that was present in the white fur, making my model look cleaner.
`Color Mix: Yellow Luminance + 35`: I brightened the yellow tones too, just to continue working on that white fur.

Final step: It's amazing how much you can transform a portrait, just by playing with the background. In this case, I felt like my model's expression and looks would be better served with blue.

`Color Mix: Purple Hue - 100`: Since the background is purple, I selected the Purple cursor and slid it to modify the Hue until I reached a blue I liked.
`Color Mix: Blue Saturation - 10`
`Color Mix: Blue Luminance + 30`: You can adjust the Luminance to your liking, which will add more separation between your model and the background.

### Color Correcting an Environmental Portrait
Our eyes neutralize the color of the lights so that we, for example, don't see the green in fluorescent lights. Refine the color to make the image look closer to how we would see it if we had been on location.

#### Color Profile
Lightroom includes a variety of Profiles to correct color and/or apply creative effects.

`Adobe Portrait`

#### Light
The image is well-exposed, but we can refine the overall exposure to tonally better shape the image.

`Exposure + 0.25`
`Contrast + 30`: Increasing contrast adds visual snap and is very appealing to our visual system.
`Highlights - 70`: Darken the bright tones to reduce the lights in the background.
`Shadows + 43`
`Curve: S-curve`

#### Color
The mixed color temperature in this image is a challenge to balance. Keep your eye on the person as that is what the image is really about - correct the color to make him look his very best.

`Temp 2525K`: Decrease Temp to make the photo more blue to offset the yellow/green color cast.
`Tint + 10`: Add a hint of magenta to counteract the greenish light.
`Color Mix: Yellow Saturation - 50`: Make the yellow tones less colorful to pull yellow out of the background.
`Color Mix: Green Saturation - 100`: Desaturate the green tones to reduce the green in the lights in the background.

#### Effects
Use the Effects to polish the image and give it visual character.

`Clarity + 10`: Accentuate details. Use low values to not exaggerate skin textures too much.
`Vignette - 25`: Darken the edges of the photo to draw more attention to him.
`Midpoint 40`: Move the midtone slider to the left to increase the spread of the vignette.
`Roundness - 15`: Adjust roundness to better fit into the scene.

#### Crop
Slightly tighten it up to make the man more prominent.
