import {Directive, ElementRef, Renderer} from 'angular2/core'

@Directive({
  selector: '[autoGrow]', // a css selector for host element. When Angular scans a template if ti finds an element that matches the css selector is going to apply this Directive on that element. The [] refers to the attribute of element.
  host: {
    '(focus)': 'onFocus()',
    '(blur)': 'onBlur()'
  }
  // it takes objects and we use hosts to subscribe to events raised from this elements.
  // we use events and the handlers in key-value pairs
})

export class AutoGrowDirective {
  // we need access to the host element and render (a service to modify that element)
  //_el: ElementRef //private field
  constructor(private el: ElementRef, private renderer: Renderer) {
    // Angular now will automatically inject  instances of Elementref and Renderer into this class
    //this._el = el
  }

  onFocus(){
    this.renderer.setElementStyle(this.el.nativeElement, 'width', '800px'); //1st arg the element you want to apply the style on, the 2nd arg is the name of the style, 3rd arg the value
  }

  onBlur(){
    this.renderer.setElementStyle(this.el.nativeElement, 'width', '300px');
  }
}
