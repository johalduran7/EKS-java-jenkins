package com.example.johnduran.cicddemo.repository;

import com.example.johnduran.cicddemo.model.Client;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClientRepository extends JpaRepository<Client, Long> {
}
