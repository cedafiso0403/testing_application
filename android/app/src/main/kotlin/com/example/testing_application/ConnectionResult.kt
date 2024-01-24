package com.example.testing_application

sealed interface ConnectionResult{
    object ConnectionEstablish: ConnectionResult
    data class Error(val message: String): ConnectionResult
}