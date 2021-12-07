import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';
import { GuidsService } from 'src/app/service/guids.service';

@Component({
  selector: 'app-default-page',
  templateUrl: './default-page.component.html',
  styleUrls: ['./default-page.component.scss'],
})
export class DefaultPageComponent implements OnInit {
  private guidRequest$: Observable<string>;
  public latestGuid: string;
  public errorMessage?: string;
  constructor(private guidsService: GuidsService) {
    this.guidRequest$ = this.guidsService.generate();
    this.latestGuid = '';
  }
  refreshGuid() {
    this.guidRequest$.subscribe(
      (res) => (this.latestGuid = res),
      (err) => (this.errorMessage = err)
    );
  }
  ngOnInit(): void {
    this.refreshGuid();
  }
}
