import {Component} from 'angular2/core';
import {CoursesComponent} from './courses.component';
import {AuthorsComponent} from './authors.component';

@Component({
    selector: 'my-app',
    template: `
      <h1>Hello World</h1>
      <courses></courses>
      <authors></authors>
      `,
    directives: [CoursesComponent, AuthorsComponent]
})
export class AppComponent { } //root of the app. It's a view component that controls the whole app/page
