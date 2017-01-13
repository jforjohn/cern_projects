import {Component} from 'angular2/core'
import {CourseService} from './course.service' // we need a reference for using the service
import {AutoGrowDirective} from './auto-grow.directive'

@Component({
  selector: 'courses', //attribute string object and it specifies a css selector for host HTML element
  // when Angular sees an element that matches the CSS selector it will create an instance or a component is the host element. Here there is an element with the tag  'courses'
  template: `
      <h2>Courses</h2>
      {{ title }}
      <input type="text" autoGrow />
      <ul>
        <li *ngFor="#course of courses">
        {{ course }}
        </li>
      </ul>
      `,
  providers: [CourseService],
  directives: [AutoGrowDirective]
  
  // with the # we declare local variables
  // ngFor is a a special attribute which is an example of a directive which extends the HTML and adds extra behaviour
  //templates: specifies the HTML that will be inserted into the DOM when the component's view is rendered. It can written here or in a seperate file.
})

export class CoursesComponent {
  title: string = "The title of courses page"; //If the value of this property in the component changes the view will be automatically refreshed (one-way binding)
  courses //= ["Course1", "Course2", "Course3"];

  constructor(courseService: CourseService) {
    //new CourseService(1, 2) -> not good because of cascading changes especially when there are more components using the service. Also, the component is not isolated for unit testing
    //dependency injection framework: to inject dependencies of the classes when creating them. Here the constructor instructs that it needs a CourseService here (this is a dependency). First, it will create an instance of the service and inject into the constructor of the class.
    // Angular CoursesComponent has a dependency on CourseService but it doesn't know how too create the service 
    this.courses = courseService.getCourses();
  }
}
