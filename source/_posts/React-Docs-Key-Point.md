---
title: React Docs Key Point
date: 2017-12-14 13:21:07
updated:
categories:
- Web
- JavaScript
tags:
- React
- Note
keywords:
- React
---

[React Docs](https://reactjs.org/docs/)

## JSX
Babel compiles JSX down to `React.createElement()` calls.
``` jsx
const element = (
  <h1 className="greeting">
    Hello, world!
  </h1>
);
```

``` jsx
const element = React.createElement(
  'h1',
  {className: 'greeting'},
  'Hello, world!'
);
```

## Component
Functional Component
``` jsx
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}
```
Class Component
``` jsx
class Welcome extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}
```
Always start component names with a capital letter.

<!-- more -->

## Prop
Props are read-only.

## State
**Use `setState()` to modify state**
**State updates may be asynchronous**
`this.props` and `this.state` may be updated asynchronously, pass a function to `setState()` for calculating the next state.
``` jsx
this.setState((prevState, props) => ({
  counter: prevState.counter + props.increment
}));
```
**State updates are merged**
**The data flows down**
State is encapsulated. It is not accessible to any component other than the one that owns and sets it. A component may choose to pass its state down as props to its child components.

## Lifecycle
``` jsx
class Clock extends React.Component {
  constructor(props) {
    super(props);
    this.state = {date: new Date()};
  }

  componentDidMount() {
    this.timerID = setInterval(
      () => this.tick(),
      1000
    );
  }

  componentWillUnmount() {
    clearInterval(this.timerID);
  }

  tick() {
    this.setState({
      date: new Date()
    });
  }

  render() {
    return (
      <div>
        <h1>Hello, world!</h1>
        <h2>It is {this.state.date.toLocaleTimeString()}.</h2>
      </div>
    );
  }
}

ReactDOM.render(
  <Clock />,
  document.getElementById('root')
);
```
1. When `<Clock />` is passed to `ReactDOM.render()`, React calls the constructor of the `Clock` component. Since `Clock` needs to display the current time, it initializes `this.state` with an object including the current time. We will later update this state.
2. React then calls the `Clock` component’s `render()` method. This is how React learns what should be displayed on the screen. React then updates the DOM to match the `Clock`’s render output.
3. When the `Clock` output is inserted in the DOM, React calls the `componentDidMount()` lifecycle hook. Inside it, the `Clock` component asks the browser to set up a timer to call the component’s `tick()` method once a second.
4. Every second the browser calls the `tick()` method. Inside it, the `Clock` component schedules a UI update by calling `setState()` with an object containing the current time. Thanks to the `setState()` call, React knows the state has changed, and calls `render()` method again to learn what should be on the screen. This time, `this.state.date` in the `render()` method will be different, and so the render output will include the updated time. React updates the DOM accordingly.
5. If the `Clock` component is ever removed from the DOM, React calls the `componentWillUnmount()` lifecycle hook so the timer is stopped.

## Handling Events
``` jsx
class LoggingButton extends React.Component {
  // This syntax ensures `this` is bound within handleClick.
  // Warning: this is *experimental* syntax.
  handleClick = () => {
    console.log('this is:', this);
  }

  render() {
    return (
      <button onClick={this.handleClick}>
        Click me
      </button>
    );
  }
}
```

### Passing Arguments to Event Handlers
``` jsx
<button onClick={(e) => this.deleteRow(id, e)}>Delete Row</button>
```

## Conditional Rendering
### Inline If with Logical && Operator
``` jsx
<div>
    <h1>Hello!</h1>
    {unreadMessages.length > 0 &&
        <h2>
            You have {unreadMessages.length} unread messages.
        </h2>
    }
</div>
```
`true && expression` always evaluates to `expression`, and `false && expression` always evaluates to `false`.

### Inline If-Else with Conditional Operator
``` jsx
<div>
    The user is <b>{isLoggedIn ? 'currently' : 'not'}</b> logged in.
</div>
```

## List and Keys
``` jsx
function ListItem(props) {
  return <li>{props.value}</li>;
}

function NumberList(props) {
  const numbers = props.numbers;
  const listItems = numbers.map((number) =>
    // Key should be specified inside the array
    <ListItem key={number.toString()}
              value={number} />
  );
  return (
    <ul>
      {listItems}
    </ul>
  );
}

const numbers = [1, 2, 3, 4, 5];
ReactDOM.render(
  <NumberList numbers={numbers} />,
  document.getElementById('root')
);
```
1. Keys must only be unique among siblings
2. Keys serve as a hint to React but they don’t get passed to your components.

## Lifting State Up
``` jsx
const scaleNames = {
  c: 'Celsius',
  f: 'Fahrenheit'
};

function toCelsius(fahrenheit) {
  return (fahrenheit - 32) * 5 / 9;
}

function toFahrenheit(celsius) {
  return (celsius * 9 / 5) + 32;
}

function tryConvert(temperature, convert) {
  const input = parseFloat(temperature);
  if (Number.isNaN(input)) {
    return '';
  }
  const output = convert(input);
  const rounded = Math.round(output * 1000) / 1000;
  return rounded.toString();
}

function BoilingVerdict(props) {
  if (props.celsius >= 100) {
    return <p>The water would boil.</p>;
  }
  return <p>The water would not boil.</p>;
}

class TemperatureInput extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    this.props.onTemperatureChange(e.target.value);
  }

  render() {
    const temperature = this.props.temperature;
    const scale = this.props.scale;
    return (
      <fieldset>
        <legend>Enter temperature in {scaleNames[scale]}:</legend>
        <input value={temperature}
               onChange={this.handleChange} />
      </fieldset>
    );
  }
}

class Calculator extends React.Component {
  constructor(props) {
    super(props);
    this.handleCelsiusChange = this.handleCelsiusChange.bind(this);
    this.handleFahrenheitChange = this.handleFahrenheitChange.bind(this);
    this.state = {temperature: '', scale: 'c'};
  }

  handleCelsiusChange(temperature) {
    this.setState({scale: 'c', temperature});
  }

  handleFahrenheitChange(temperature) {
    this.setState({scale: 'f', temperature});
  }

  render() {
    const scale = this.state.scale;
    const temperature = this.state.temperature;
    const celsius = scale === 'f' ? tryConvert(temperature, toCelsius) : temperature;
    const fahrenheit = scale === 'c' ? tryConvert(temperature, toFahrenheit) : temperature;

    return (
      <div>
        <TemperatureInput
          scale="c"
          temperature={celsius}
          onTemperatureChange={this.handleCelsiusChange} />
        <TemperatureInput
          scale="f"
          temperature={fahrenheit}
          onTemperatureChange={this.handleFahrenheitChange} />
        <BoilingVerdict
          celsius={parseFloat(celsius)} />
      </div>
    );
  }
}

ReactDOM.render(
  <Calculator />,
  document.getElementById('root')
);

```
There should be a single “source of truth” for any data that changes in a React application. Usually, the state is first added to the component that needs it for rendering. Then, if other components also need it, you can lift it up to their closest common ancestor. Instead of trying to sync the state between different components, you should rely on the top-down data flow.

## Composition
Use composition instead of inheritance to reuse code between components.

### Containment
``` jsx
function FancyBorder(props) {
  return (
    <div className={'FancyBorder FancyBorder-' + props.color}>
      {props.children}
    </div>
  );
}

function WelcomeDialog() {
  return (
    <FancyBorder color="blue">
      <h1 className="Dialog-title">
        Welcome
      </h1>
      <p className="Dialog-message">
        Thank you for visiting our spacecraft!
      </p>
    </FancyBorder>
  );
}
```

### Specialization
``` jsx
function Dialog(props) {
  return (
    <FancyBorder color="blue">
      <h1 className="Dialog-title">
        {props.title}
      </h1>
      <p className="Dialog-message">
        {props.message}
      </p>
    </FancyBorder>
  );
}

function WelcomeDialog() {
  return (
    <Dialog
      title="Welcome"
      message="Thank you for visiting our spacecraft!" />
  );
}
```

## Thinking in React
1. Start with a mock
2. Break the UI into a component hierarchy: single responsibility principle
3. Build a static version in react: don’t use state to build this static version
4. Identify the minimal (but complete) representation of UI state: DRY(Don’t Repeat Yourself)
    1. Is it passed in from a parent via props? If so, it probably isn’t state.
    2. Does it remain unchanged over time? If so, it probably isn’t state.
    3. Can you compute it based on any other state or props in your component? If so, it isn’t state.
5. Identify where your state should live
6. Add inverse data flow

## Typechecking With PropTypes
`PropTypes` exports a range of validators that can be used to make sure the data you receive is valid. When an invalid value is provided for a prop, a warning will be shown in the JavaScript console. For performance reasons, `propTypes` is only checked in development mode.
``` jsx
import PropTypes from 'prop-types';

class Greeting extends React.Component {
  render() {
    return (
      <h1>Hello, {this.props.name}</h1>
    );
  }
}

Greeting.propTypes = {
  name: PropTypes.string
};
```

## Static Type Checking
Use [Flow](https://flow.org) or [TypeScript](https://www.typescriptlang.org) as static type checkers.

### Using TypeScript with Create React App
- [react-scripts-ts](https://www.npmjs.com/package/react-scripts-ts)
- [TypeScript-React-Starter](https://github.com/Microsoft/TypeScript-React-Starter)

## Refs and the DOM
There are a few good use cases for refs:
- Managing focus, text selection, or media playback
- Triggering imperative animations
- Integrating with third-party DOM libraries

The ref attribute can't be used on functional components because they don’t have instances.

### Adding a Ref to a DOM Element
``` jsx
class CustomTextInput extends React.Component {
  constructor(props) {
    super(props);
    this.focusTextInput = this.focusTextInput.bind(this);
  }

  focusTextInput() {
    // Explicitly focus the text input using the raw DOM API
    this.textInput.focus();
  }

  render() {
    // Use the `ref` callback to store a reference to the text input DOM
    // element in an instance field (for example, this.textInput).
    return (
      <div>
        <input
          type="text"
          ref={(input) => { this.textInput = input; }} />
        <input
          type="button"
          value="Focus the text input"
          onClick={this.focusTextInput}
        />
      </div>
    );
  }
}
```

### Adding a Ref to a Class Component
``` jsx
class AutoFocusTextInput extends React.Component {
  componentDidMount() {
    this.textInput.focusTextInput();
  }

  render() {
    return (
      <CustomTextInput
        ref={(input) => { this.textInput = input; }} />
    );
  }
}

class CustomTextInput extends React.Component {
  // ...
}
```

## Optimizing Performance
### Use the Production Build
In **Create React App**: `npm run build` creates a production build; `npm start` creates a development build.

### Virtualize Long Lists
[React Virtualized](https://bvaughn.github.io/react-virtualized/) is one popular windowing library. It provides several reusable components for displaying lists, grids, and tabular data.

### Avoid Reconciliation
If the only way your component ever changes is when the `props.color` or the `state.count` variable changes, you could have `shouldComponentUpdate` check that:
``` jsx
class CounterButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {count: 1};
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (this.props.color !== nextProps.color) {
      return true;
    }
    if (this.state.count !== nextState.count) {
      return true;
    }
    return false;
  }

  render() {
    return (
      <button
        color={this.props.color}
        onClick={() => this.setState(state => ({count: state.count + 1}))}>
        Count: {this.state.count}
      </button>
    );
  }
}
```
`React.PureComponent` does a **shallow comparison** between all the fields of props and state to determine if the component should update.
``` jsx
class CounterButton extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {count: 1};
  }

  render() {
    return (
      <button
        color={this.props.color}
        onClick={() => this.setState(state => ({count: state.count + 1}))}>
        Count: {this.state.count}
      </button>
    );
  }
}
```

### The Power Of Not Mutating Data
Array spread syntax
``` jsx
handleClick() {
  this.setState(prevState => ({
    words: [...prevState.words, 'marklar'],
  }));
};
```
Object spread syntax
``` jsx
function updateColorMap(colormap) {
  return {...colormap, right: 'blue'};
}
```

## Reconciliation
When you use React, at a single point in time you can think of the `render()` function as creating a tree of React elements. On the next state or props update, that `render()` function will return a different tree of React elements. React then needs to figure out how to efficiently update the UI to match the most recent tree.
React implements a heuristic `O(n)` algorithm based on two assumptions:
1. Two elements of different types will produce different trees.
2. The developer can hint at which child elements may be stable across different renders with a key prop.

### The Diffing Algorithm
When diffing two trees, React first compares the two root elements. The behavior is different depending on the types of the root elements.

**Elements Of Different Types**: Whenever the root elements have different types, React will tear down the old tree and build the new tree from scratch.

**DOM Elements Of The Same Type**: When comparing two React DOM elements of the same type, React looks at the attributes of both, keeps the same underlying DOM node, and only updates the changed attributes.

**Component Elements Of The Same Type**: When a component updates, the instance stays the same, so that state is maintained across renders. React updates the props of the underlying component instance to match the new element, and calls `componentWillReceiveProps()` and `componentWillUpdate()` on the underlying instance.

**Recursing On Children**: By default, when recursing on the children of a DOM node, React just iterates over both lists of children at the same time and generates a mutation whenever there’s a difference.

**Keys**: When children have keys, React uses the key to match children in the original tree with children in the subsequent tree.
The key only has to be unique among its siblings, not globally unique. You can pass an item’s index in the array as a key, but this only works well when the items are never reordered.

## Fragments
Fragments let you group a list of children without adding extra nodes to the DOM.
``` jsx
class Table extends React.Component {
  render() {
    return (
      <table>
        <tr>
          <Columns />
        </tr>
      </table>
    );
  }
}

class Columns extends React.Component {
  render() {
    return (
      <React.Fragment>
        <td>Hello</td>
        <td>World</td>
      </React.Fragment>
    );
  }
}
```
This results in a correct `<Table />` output:
``` jsx
<table>
  <tr>
    <td>Hello</td>
    <td>World</td>
  </tr>
</table>
```

## Portals
Portals provide a first-class way to render children into a DOM node that exists outside the DOM hierarchy of the parent component.
``` jsx
render() {
  return ReactDOM.createPortal(
    this.props.children,
    domNode
  );
}
```
A typical use case for portals is when a parent component has an `overflow: hidden` or `z-index` style, but you need the child to visually “break out” of its container. For example, dialogs, hovercards, and tooltips.

## create-react-app
[Supported Language Features and Polyfills](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#supported-language-features-and-polyfills)
[Debugging in the Editor](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#debugging-in-the-editor)
[Formatting Code Automatically](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#formatting-code-automatically)
[Progressive Web App](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#making-a-progressive-web-app)
[Deploying on GitHub Pages](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#github-pages)
