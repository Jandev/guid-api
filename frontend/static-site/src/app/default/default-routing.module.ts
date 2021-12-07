import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { DefaultPageComponent } from './default-page/default-page.component';

const routes: Routes = [{ path: 'default', component: DefaultPageComponent }];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class DefaultRoutingModule {}
