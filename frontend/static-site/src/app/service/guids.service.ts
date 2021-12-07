import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { catchError, Observable, throwError } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root',
})
export class GuidsService {
  private backendUrl: string;

  constructor(private http: HttpClient) {
    this.backendUrl = environment.backendUrl;
  }

  public generate(): Observable<string> {
    let url = `${this.backendUrl}/api/DefaultNewGuid`;
    return this.http.get(url, { responseType: 'text' });
    // .pipe(
    //   catchError((error) => {
    //     let errorMsg: string;
    //     if (error.error instanceof ErrorEvent) {
    //       errorMsg = error.error.message;
    //     } else {
    //       errorMsg = error.message;
    //     }

    //     return throwError(errorMsg);
    //   })
    // );
  }
}
